
# Installation

The following installation guidance is derived from [the original repository of CodeS](https://github.com/RUCKBReasoning/codes).

#### Step1: Install Java
```
apt-get update
apt-get install -y openjdk-11-jdk
```
If you already have a Java environment installed, you can skip this step.

#### Step2: Create Python Environments
```
conda create -n CodeS python=3.9 -y
conda activate CodeS
pip install -r requirements.txt
git clone https://github.com/lihaoyang-ruc/SimCSE.git
cd SimCSE
python setup.py install
cd ..
```

#### Step3: Download Checkpoints
Download the schema item classifier checkpoints [sic_ckpts.zip](https://drive.google.com/file/d/1V3F4ihTSPbV18g3lrg94VMH-kbWR_-lY/view?usp=sharing) and unzip it:
```
unzip sic_ckpts.zip
```

Download the SFT model `seeklhy/codes-7b-merged`  from:
```
https://huggingface.co/seeklhy/codes-7b-merged/tree/main
```

Since we release Spider2-SQL as a pure test-set (without its corresponding train-set), few-shot in-context learning is infeasible. By default we use `seeklhy/codes-7b-merged` to enhance the model's ability to generalize to the unseen Spider2-SQL domain. **For quick deployment, you may opt to use the smaller `seeklhy/codes-1b` model instead.**


# Running
Replace the VPN launch approach below with your own method, to gain access to Google BigQuery:
```
export https_proxy=http://127.0.0.1:15777 http_proxy=http://127.0.0.1:15777
```
Then, simply run :laughing::
```
bash run.sh
```
this script automatically conducts all procedures: 1) data preprocess, 2) executing CodeS, 3) evaluation. You can find the output SQL in `spider2-lite/baselines/codes/postprocessed_data`.



# Evaluation

## Experimental Setting

We use the CodeS-7b pretrained on the merged dataset provided by the CodeS paper, and use schema item classifier pretrained on BIRD. Similar to the evaluation setting of [DailSQL](https://github.com/xlang-ai/spider2/tree/main/spider2-baselines/DailSQL), the performance is shown as:

| Method                  | Score   |    Score  [w/ Func & w/ Plan]     |
| -------------------------- | ---- | -------------------------
| CodeS-7B      | 2.19% (7/319) |   2.50% (8/319)            |

## Prompts

Take `bq076` as example, prompt of CodeS is as:
```
database schema :
table crime , columns = [ crime.date ( TIMESTAMP | values : 2023-12-02 20:00:00+00:00 ) , crime.iucr ( STRING | values : 0281 ) , crime.primary_type ( STRING | values : CRIMINAL SEXUAL ASSAULT ) , crime.year ( INT64 | values : 2023 ) , crime.case_number ( STRING | values : JH130429 ) , crime.unique_key ( INT64 | values : 13350090 ) , crime.block ( STRING | values : 0000X E WACKER PL ) , crime.description ( STRING | values : NON-AGGRAVATED ) , crime.domestic ( BOOL | values : False ) , crime.ward ( INT64 | values : 42 ) ]
foreign keys : None
matched contents : None
Which month generally has the greatest number of motor vehicle thefts in 2016?
```
The additional prompt of setting [w/ Func & w/ Plan] is as:
```
potentially useful special functions with their usage:date-functions/DATE: Constructs a ` DATE ` value.
date-functions/EXTRACT: Extracts part of a date from a ` DATE ` value.
datetime-functions/EXTRACT: Extracts part of a date and time from a ` DATETIME ` value.
interval-functions/EXTRACT: Extracts part of an ` INTERVAL ` value.
numbering-functions/RANK: Gets the rank (1-based) of each row within a window.
time-functions/EXTRACT: Extracts part of a ` TIME ` value.
timestamp-functions/EXTRACT: Extracts part of a ` TIMESTAMP ` value.
a plan that is useful for guiding the generation of components of a complete SQL query:Which month generally has the greatest number of motor vehicle thefts?
The following query summarizes the number of MOTOR VEHICLE THEFT incidents for each year and month, and ranks the month’s total from 1 to 12. Then, the outer SELECT clause limits the final result set to the first overall ranking for each year. According to the data, in 3 of the past 10 years, December had the highest number of car thefts
Which month generally has the greatest number of motor vehicle thefts in 2016?
```
