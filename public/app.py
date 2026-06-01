import os
import base64
import time
import json
import asyncio
import tempfile
import requests
from flask import Flask, request
from flask_socketio import SocketIO, emit
from groq import Groq
import edge_tts

# ================= 配置区域 =================

# 1. SiliconFlow (LLM) 配置 - 使用 Qwen 2.5 实现极速响应
# 您提供的硅基流动 Key
SILICON_API_KEY = "sk-ebajtpegvxdlsvkaeoiqkrwuzusqusizkkziymhcdjugdxrj"  
LLM_MODEL = "Qwen/Qwen2.5-72B-Instruct" # 速度快，情商高，适合语音

# 2. Groq (STT) 配置 - 语音转文字
# 您提供的 Groq Key
GROQ_API_KEY = "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"     

# 3. 系统人设 - 治愈系风格
SYSTEM_PROMPT = """
你叫“灵犀”，是一个温暖、富有同理心的心理疗愈师。
你的声音温柔，像一位老朋友。
请用简短、口语化、温暖的语气回答。
不要长篇大论，每次回答控制在2-3句话以内，因为这是语音对话。
禁止使用Markdown格式，禁止使用表情符号（因为要转语音）。
"""

# 4. 幻觉词黑名单 (解决 Whisper 识别出“李宗盛”等问题)
# 如果识别结果包含这些词，且长度很短，视为无效录音
HALLUCINATION_Keywords = [
    "字幕志愿者", "李宗盛", "未经许可", "VX", "微信", 
    "Subtitle", "Amara", "org", "Copyright", "版权"
]

# ===========================================

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")
groq_client = Groq(api_key=GROQ_API_KEY)

def is_hallucination(text):
    """检查是否为语音识别模型的幻觉"""
    if not text or len(text.strip()) < 2:
        return True
    for kw in HALLUCINATION_Keywords:
        if kw in text:
            print(f"⚠️ 拦截幻觉文本: {text}")
            return True
    return False

async def generate_tts(text, output_filename):
    """使用 Edge-TTS 生成语音"""
    # 推荐声音: zh-CN-XiaoxiaoNeural (温暖女声) 或 zh-CN-YunxiNeural (沉稳男声)
    try:
        communicate = edge_tts.Communicate(text, "zh-CN-XiaoxiaoNeural", rate="+0%", pitch="+0Hz")
        await communicate.save(output_filename)
    except Exception as e:
        print(f"TTS生成失败: {e}")
        raise e

def process_audio_flow(audio_base64):
    """核心处理流程：语音 -> 文本 -> AI -> 语音"""
    # 使用唯一文件名避免冲突
    unique_id = str(time.time())
    temp_webm = f"temp_input_{unique_id}.webm"
    temp_mp3 = f"temp_output_{unique_id}.mp3"
    
    try:
        # 1. 保存用户录音
        with open(temp_webm, "wb") as f:
            f.write(base64.b64decode(audio_base64))
        
        # 2. STT: Groq 语音转文字
        print("👂 正在听...")
        with open(temp_webm, "rb") as file:
            transcription = groq_client.audio.transcriptions.create(
                file=(temp_webm, file.read()),
                model="whisper-large-v3",
                prompt="普通话。Conversational spoken Chinese.", # 提示词，提高准确率
                response_format="json",
                language="zh"
            )
        user_text = transcription.text.strip()
        print(f"📝 识别内容: {user_text}")

        # 3. 幻觉过滤
        if is_hallucination(user_text):
            print("🚫 忽略无效输入")
            emit('ui_feedback', {'state': 'thinking', 'text': '...'}) 
            return

        # 发送识别出的文字给前端展示
        emit('ui_feedback', {'state': 'thinking', 'text': user_text})

        # 4. LLM: SiliconFlow 获取回复
        print("🧠 思考中...")
        headers = {
            "Authorization": f"Bearer {SILICON_API_KEY}",
            "Content-Type": "application/json"
        }
        payload = {
            "model": LLM_MODEL,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_text}
            ],
            "stream": False,
            "max_tokens": 150 # 限制回复长度，加快速度
        }
        
        start_time = time.time()
        response = requests.post("https://api.siliconflow.cn/v1/chat/completions", json=payload, headers=headers)
        
        if response.status_code != 200:
            print(f"SiliconFlow Error: {response.text}")
            raise Exception("AI服务响应异常")
            
        ai_text = response.json()['choices'][0]['message']['content']
        print(f"💡 AI回复 ({time.time() - start_time:.2f}s): {ai_text}")

        # 发送 AI 文本给前端
        emit('ui_feedback', {'state': 'speaking', 'text': ai_text})

        # 5. TTS: 文字转语音
        print("🗣️ 生成语音...")
        asyncio.run(generate_tts(ai_text, temp_mp3))

        # 读取生成的 MP3 并转为 Base64
        with open(temp_mp3, "rb") as f:
            audio_data = f.read()
            audio_b64 = base64.b64encode(audio_data).decode('utf-8')

        # 发送音频给前端播放
        emit('play_audio', {'audio': audio_b64})
        print("✅ 完成交互")

    except Exception as e:
        print(f"❌ 错误: {str(e)}")
        emit('ui_feedback', {'text': '抱歉，我走神了...'})
    finally:
        # 清理临时文件
        if os.path.exists(temp_webm): os.remove(temp_webm)
        if os.path.exists(temp_mp3): os.remove(temp_mp3)

@socketio.on('connect')
def handle_connect():
    print('🔌 客户端已连接')

@socketio.on('disconnect')
def handle_disconnect():
    print('🔌 客户端断开')

@socketio.on('submit_audio')
def handle_audio(data):
    # 使用 socketio 的后台任务来处理，避免阻塞心跳
    socketio.start_background_task(process_audio_flow, data['audio'])

if __name__ == '__main__':
    print("🚀 服务已启动: http://127.0.0.1:5566")
    try:
        socketio.run(app, debug=True, port=5566, allow_unsafe_werkzeug=True)
    except SystemExit:
        pass