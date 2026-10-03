#!/bin/bash
ollama serve &
sleep 2
cd ~/odysseus
source venv/bin/activate
python -m uvicorn app:app --host 127.0.0.1 --port 7000 &
sleep 3
helium http://localhost:7000
