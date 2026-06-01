import os, asyncio, requests, edge_tts, json, datetime
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# --- 配置区 ---
API_KEY = "sk-ebajtpegvxdlsvkaeoiqkrwuzusqusizkkziymhcdjugdxrj"
API_URL = "https://api.siliconflow.cn/v1/chat/completions"
MODEL = "deepseek-ai/DeepSeek-V2.5"
VOICE = "zh-CN-XiaoxiaoNeural"

# 全量注入 20 个核心访谈脉络
SYSTEM_PROMPT = """
你叫“豆芽小熊”，是专业生命纪录官。你的核心任务是引导长辈按以下 20 个问题主线完成自传。
【引导原则】：
1. 每次只提一个问题。先共情，再抛出脉络中的下一个问题。
2. 具象化引导：多问感官细节。
3. 访谈脉络：童年根源 -> 青春转折 -> 心灵纽带 -> 生命挑战 -> 岁月智慧。
"""

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    u_info = data.get('userInfo', {})
    u_text = data.get('text', "").strip()
    history = data.get('history', [])
    
    # 提取关键信息
    u_name = u_info.get('name', '未知')
    u_phone = u_info.get('phone', '未提供')
    u_gender = "男" if u_info.get('gender') == 'male' else "女"
    title = "爷爷" if u_info.get('gender') == 'male' else "奶奶"
    
    filename = f"访谈录_{u_name}_{datetime.date.today()}.txt"

    if not history:
        history.append({"role": "system", "content": SYSTEM_PROMPT})

    try:
        # 1. 调用 AI
        res = requests.post(API_URL, json={
            "model": MODEL, 
            "messages": history + [{"role": "user", "content": u_text}],
            "temperature": 0.7
        }, headers={'Authorization': f'Bearer {API_KEY}', 'Content-Type': 'application/json'})
        
        ai_text = res.json()['choices'][0]['message']['content']

        # 2. ✨ 后端实时日志打印 (现在包含联系方式) ✨
        print(f"\n[访谈记录] 长辈: {u_name} | 性别: {u_gender} | 联系方式: {u_phone}")
        print(f"【{title} 说】: {u_text}")
        print(f"【小熊 说】: {ai_text}")
        print("-" * 50)

        # 3. 写入本地文件存档
        with open(filename, "a", encoding="utf-8") as f:
            ts = datetime.datetime.now().strftime("%H:%M:%S")
            f.write(f"[{ts}] 用户:{u_name} | 联系方式:{u_phone}\n")
            f.write(f"[{ts}] {title}: {u_text}\n")
            f.write(f"[{ts}] 小熊: {ai_text}\n\n")

        # 4. 语音合成
        audio_file = "reply.mp3"
        async def tts(): await edge_tts.Communicate(ai_text, VOICE, pitch="+12Hz", rate="+12%").save(audio_file)
        asyncio.run(tts())

        return jsonify({"chat_text": ai_text, "audio_url": f"http://127.0.0.1:5000/get_audio?v={os.urandom(4).hex()}"})
    except Exception as e:
        print(f"发生错误: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/get_audio')
def get_audio(): return send_file("reply.mp3", mimetype="audio/mpeg")

if __name__ == '__main__': app.run(port=5000)