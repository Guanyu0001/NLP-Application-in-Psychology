# A Bibliometric Review of Natural Language Processing Applications in Psychology from 1991 to 2023

## Project Overview
The R and Python code for the following publication is provided here.
Chen, G., Tan, B., Laham, N., Tracey, T., Lapinski, S., & Liu, Y. (2024). A review of natural language processing applications in psychology from 1991 to 2020. Basic and Applied Social Psychology. DOI: 10.1080/01973533.2024.2433720

## Files and Their Purpose

### `abstract_updated.csv`
Main dataset containing research paper abstracts and metadata for clustering analysis in `k_means_v0.4.0.ipynb`.

### `k_means_v0.4.0.ipynb`
Jupyter Notebook implementing k-means clustering to identify thematic clusters in NLP research using `abstract_updated.csv`.

### `bib_updated.RData`
R data file with processed bibliometric data for statistical analysis in `analysis_v2.R`.

### `analysis_v2.R`
R script performing statistical and visual analysis of bibliometric data from `bib_updated.RData`.

### `burst_detection_updated.py`
Python script analyzing bibliometric data to detect significant temporal research trends or "bursts."


## Getting Started

### Prerequisites
To run the scripts and notebooks, ensure you have the following installed:
- **Python** (for Jupyter Notebooks and Python scripts)
- **R** (for running R scripts)
- Necessary libraries and dependencies listed in the respective scripts.

### Steps
1. Clone this repository:
   ```bash
   git clone https://github.com/Guanyu0001/NLP-Application-in-Psychology.git
   cd NLP-Application-in-Psychology