# A Bibliometric Review of Natural Language Processing Applications in Psychology from 1991 to 2023

## Project Overview
The R and Python code for the following publication is provided here.
Chen, G., Tan, B., Laham, N., Tracey, T., Lapinski, S., & Liu, Y. (2024). A review of natural language processing applications in psychology from 1991 to 2020. Basic and Applied Social Psychology. DOI: 10.1080/01973533.2024.2433720

## Files and Their Purpose

### `abstract_updated.csv`
- **Purpose**: Input dataset for the `k_means_v0.4.0.ipynb` notebook.
- **Description**: This CSV file contains the abstracts and metadata of the research papers analyzed. It serves as the main dataset for the clustering analysis.

### `k_means_v0.4.0.ipynb`
- **Purpose**: Jupyter Notebook for performing k-means clustering.
- **Description**: Implements k-means clustering on the `abstract_updated.csv` dataset, helping identify thematic clusters in NLP research within psychology.

### `bib_updated.RData`
- **Purpose**: Input data for the `analysis_v2.R` script.
- **Description**: An R data file containing processed bibliometric data required for further statistical analysis and visualization.

### `analysis_v2.R`
- **Purpose**: R script for bibliometric analysis.
- **Description**: Performs statistical and visual analysis of bibliometric data using the `bib_updated.RData` file.

### `burst_detection_updated.py`
- **Purpose**: Python script for burst detection.
- **Description**: Analyzes temporal trends in bibliometric data to detect significant "bursts" or trends in research activity.

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

