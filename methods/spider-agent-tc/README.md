# Tool-call Agent for Spider 2.0-Snow

This folder contains the Spider-Agent implementation for Spider2.0-Snow using a tool function call format, enabling quick benchmarking without Docker dependency.

The performance matches the Docker-based Spider-Agent while being more convenient and faster to run.

## Usage

1. Configure credential: Follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Snowflake_Guideline.md) to get your own Snowflake username and password in our snowflake database. Put this in `./methods/spider-agent-tc/credentials` folder.

2. Run scripts

```bash
cd methods/spider-agent-tc

# Modify the parameters in the script before running
# the DATABASES_PATH must be the absolute path
bash run.sh
```

## Extract Submission

```bash
python convert_to_submission_format.py /path/to/methods/spider-agent-tc/results/{output_dir} /path/to/spider2-snow/evaluation_suite/{output_dir}
```

**Note:** Replace `<results_output_dir>` with your actual results directory path and update the evaluation suite path accordingly.