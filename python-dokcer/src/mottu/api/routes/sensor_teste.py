# src/mottu/api/routes/sensor.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from mottu.database.connection import SessionLocal
from mottu.database.models import SensorData

router = APIRouter()

# Dependência para injetar sessão
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/sensor")
def criar_sensor(tipo_sensor: str, valor: float, db: Session = Depends(get_db)):
    dado = SensorData(tipo_sensor=tipo_sensor, valor=valor)
    db.add(dado)
    db.commit()
    db.refresh(dado)
    return {"id": dado.id, "mensagem": "Sensor registrado com sucesso!"}

@router.get("/sensor")
def listar_sensores(db: Session = Depends(get_db)):
    sensores = db.query(SensorData).all()
    return sensores


@router.delete("/sensor/{sensor_id}")
def deletar_sensor(sensor_id: int, db: Session = Depends(get_db)):
    sensor = db.query(SensorData).filter(SensorData.id == sensor_id).first()
    if not sensor:
        return {"erro": "Sensor não encontrado."}
    
    db.delete(sensor)
    db.commit()
    return {"mensagem": f"Sensor com ID {sensor_id} deletado com sucesso."}