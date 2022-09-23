import torch
from huggingface_hub.commands.user import _login
from diffusers import StableDiffusionPipeline
from torch import autocast
import io
from fastapi import FastAPI, Response
import asyncio
from fastapi.middleware.cors import CORSMiddleware
import nest_asyncio
import uvicorn
from huggingface_hub import HfFolder
import os

HfFolder.save_token(os.getenv('HUGGING_FACE'))

pipe = StableDiffusionPipeline.from_pretrained("CompVis/stable-diffusion-v1-4", revision="fp16", torch_dtype=torch.float16, use_auth_token=True)
pipe = pipe.to("cuda")

def dream(prompt: str):
  with autocast("cuda"):
    image = pipe(prompt, num_inference_steps=50)["sample"][0]  

  byteIO = io.BytesIO()
  image.save(byteIO, format='PNG')
  return byteIO.getvalue()

dream("warm up") ## warms up, proven to serve faster after the first call

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

@app.get("/dreams")
async def dreams(prompt: str):
    return Response(content=dream(prompt), media_type="image/png")

@app.get("/status")
async def status():
    return Response(status_code=200)

nest_asyncio.apply()
uvicorn.run(app, port=8000)
