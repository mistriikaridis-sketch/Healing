"""
静屿灵犀后端服务
运行方式: python server.py
默认端口: 5566
"""

import asyncio
import base64
import json
import logging
from datetime import datetime
from aiohttp import web
from aiohttp_cors import setup as cors_setup, ResourceOptions

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class LingxiServer:
    """灵犀对话服务"""

    def __init__(self):
        self.clients = {}  # client_id -> websocket
        self.pending_audio = {}  # client_id -> audio_data

    async def handle_audio(self, data: dict) -> dict:
        """处理音频数据"""
        audio_base64 = data.get('audio', '')

        # 这里可以集成语音识别(ASR)
        # 示例: 使用百度/讯飞/阿里云 ASR API
        text = await self.recognize_speech(audio_base64)

        # 调用 AI 对话生成回复
        response_text = await self.generate_response(text)

        # 将回复转换为语音(TTS)
        # 示例: 使用百度/讯飞/阿里云 TTS API
        audio_response = await self.synthesize_speech(response_text)

        return {
            'type': 'response',
            'text': response_text,
            'audio': audio_response,
            'timestamp': datetime.now().isoformat()
        }

    async def recognize_speech(self, audio_base64: str) -> str:
        """语音识别 - 需要接入 ASR 服务"""
        # 示例实现 - 实际需要调用 ASR API
        try:
            # 解码音频
            audio_data = base64.b64decode(audio_base64)

            # TODO: 调用 ASR API (百度/讯飞/阿里云/OpenAI Whisper)
            # 以下是使用 OpenAI Whisper 的示例:
            # from openai import OpenAI
            # client = OpenAI()
            # with open('temp_audio.mp3', 'wb') as f:
            #     f.write(audio_data)
            # with open('temp_audio.mp3', 'rb') as f:
            #     transcript = client.audio.transcriptions.create(
            #         model="whisper-1",
            #         file=f
            #     )
            # return transcript.text

            # 模拟返回
            return "我听到你了，请继续说"
        except Exception as e:
            logger.error(f"语音识别错误: {e}")
            return ""

    async def generate_response(self, user_text: str) -> str:
        """AI 对话生成 - 需要接入 LLM 服务"""
        # 示例实现 - 实际需要调用 LLM API
        try:
            # TODO: 调用 LLM API (OpenAI GPT / Claude / 文心一言)
            # 以下是使用 OpenAI 的示例:
            # from openai import OpenAI
            # client = OpenAI()
            # response = client.chat.completions.create(
            #     model="gpt-4",
            #     messages=[
            #         {"role": "system", "content": "你是一个温暖的心理疗愈助手..."},
            #         {"role": "user", "content": user_text}
            #     ]
            # )
            # return response.choices[0].message.content

            # 模拟回复
            responses = [
                "我理解你的感受。",
                "谢谢你分享这些。",
                "这听起来是很重要的事情。",
                "我在这里陪伴你。",
                "深呼吸，让自己放松下来。",
            ]
            import random
            return random.choice(responses)
        except Exception as e:
            logger.error(f"AI 生成回复错误: {e}")
            return "我在这里，陪伴你。"

    async def synthesize_speech(self, text: str) -> str:
        """语音合成 - 需要接入 TTS 服务"""
        # 示例实现 - 实际需要调用 TTS API
        try:
            # TODO: 调用 TTS API (百度/讯飞/阿里云/OpenAI)
            # 以下是使用 OpenAI TTS 的示例:
            # from openai import OpenAI
            # client = OpenAI()
            # response = client.audio.speech.create(
            #     model="tts-1",
            #     voice="alloy",
            #     input=text
            # )
            # response.stream_to_file("temp_output.mp3")
            # with open("temp_output.mp3", "rb") as f:
            #     audio_base64 = base64.b64encode(f.read()).decode()
            # return audio_base64

            # 返回空的 base64 (模拟)
            return ""
        except Exception as e:
            logger.error(f"语音合成错误: {e}")
            return ""

# 创建服务实例
server = LingxiServer()

async def websocket_handler(request: web.Request) -> web.WebSocketResponse:
    """WebSocket 处理"""
    ws = web.WebSocketResponse()
    await ws.prepare(request)

    client_id = id(ws)
    server.clients[client_id] = ws
    logger.info(f"客户端已连接: {client_id}")

    try:
        async for msg in ws:
            if msg.type == web.WSMsgType.TEXT:
                try:
                    data = json.loads(msg.data)

                    if data.get('type') == 'audio':
                        # 处理音频
                        response = await server.handle_audio(data)
                        await ws.send_json(response)

                    elif data.get('type') == 'text':
                        # 处理文本
                        response_text = await server.generate_response(data.get('data', ''))
                        await ws.send_json({
                            'type': 'response',
                            'text': response_text,
                            'state': 'speaking'
                        })

                    elif data.get('type') == 'ping':
                        await ws.send_json({'type': 'pong'})

                except json.JSONDecodeError:
                    logger.error("JSON 解析错误")
                except Exception as e:
                    logger.error(f"处理消息错误: {e}")

            elif msg.type == web.WSMsgType.ERROR:
                logger.error(f"WebSocket 错误: {ws.exception()}")

    finally:
        del server.clients[client_id]
        logger.info(f"客户端已断开: {client_id}")

    return ws

async def index_handler(request: web.Request) -> web.Response:
    """首页"""
    return web.Response(
        text="""
        <html>
            <head><title>静屿灵犀后端</title></head>
            <body>
                <h1>静屿灵犀后端服务</h1>
                <p>状态: 运行中</p>
                <p>WebSocket 端点: ws://localhost:5566/ws</p>
            </body>
        </html>
        """,
        content_type='text/html'
    )

async def health_handler(request: web.Request) -> web.Response:
    """健康检查"""
    return web.json_response({
        'status': 'ok',
        'timestamp': datetime.now().isoformat(),
        'connections': len(server.clients)
    })

async def stats_handler(request: web.Request) -> web.Response:
    """统计信息"""
    return web.json_response({
        'total_connections': len(server.clients),
        'pending_audio': len(server.pending_audio)
    })

async def on_startup(app: web.Application):
    """应用启动"""
    logger.info("静屿灵犀后端服务已启动")
    logger.info("WebSocket 端点: ws://localhost:5566/ws")

async def on_shutdown(app: web.Application):
    """应用关闭"""
    logger.info("正在关闭所有连接...")
    for ws in server.clients.values():
        await ws.close()
    logger.info("静屿灵犀后端服务已关闭")

def create_app() -> web.Application:
    """创建应用"""
    app = web.Application()

    # 配置 CORS
    cors_config = {
        "*": ResourceOptions(
            allow_credentials=True,
            allow_headers=["Content-Type", "Authorization"],
            allow_methods=["GET", "POST", "OPTIONS"],
        )
    }
    cors = cors_setup(app, defaults=cors_config)

    # 添加路由
    app.add_routes([
        web.get('/', index_handler),
        web.get('/health', health_handler),
        web.get('/stats', stats_handler),
        web.get('/ws', websocket_handler),
    ])

    # 生命周期钩子
    app.on_startup.append(on_startup)
    app.on_shutdown.append(on_shutdown)

    return app

if __name__ == '__main__':
    app = create_app()
    web.run_app(app, host='0.0.0.0', port=5566)
