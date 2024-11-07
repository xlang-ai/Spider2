# Installation 

Set up the Python environment:
```
conda create -n DIN-SQL python=3.9
conda activate DIN-SQL
cd spider2-lite/baselines/dinsql
pip install -r requirements.txt
```

# Running

Export your OpenAI API key:
```
export OPENAI_API_KEY=YOUR_OPENAI_API_KEY
```

Replace the VPN launch approach below with your own method, to gain access to OpenAI and Google BigQuery:
```
export https_proxy=http://127.0.0.1:15777 http_proxy=http://127.0.0.1:15777
```

Finally, simply run :laughing::
```
bash run.sh
```
