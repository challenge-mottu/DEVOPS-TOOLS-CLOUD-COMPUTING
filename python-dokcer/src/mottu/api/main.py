# src/mottu/api/main.py

from fastapi import FastAPI
from mottu.api.routes import sensor_teste

app = FastAPI()

app.include_router(sensor_teste.router)
