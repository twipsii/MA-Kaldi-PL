# Master's thesis on Pronunciation Lexicon in Swiss German ASR

## Description

This repository contains the Kaldi recipe and data used to train Swiss German ASR systems in the course of the Master's thesis in 2020. The main focus was on the Pronunciation Lexicon (PL) which is compiled based on the [_Swiss German Dictionary_](https://www.spur.uzh.ch/en/departments/research/textgroup/Swisscom-s-Swiss-German-Dictionary.html). I investigated how the PL can be extended with Grapheme-to-Phoneme (G2P) conversion. Furthermore, I looked at how it impacts the performance of the ASR model when using different PLs at the two stages within the ASR system: training of the Acoustic Model (AM) and decoding.

The following sections describe how the Kaldi framework is structured and how to use the code to train, decode and evaluate an ASR model.

The Kaldi (version 5.5) recipe egs/wsj/s5 (commit 8cc5c8b32a49f8d963702c6be681dcf5a55eeb2e) was used as a reference. For the TDNN acoustic model, the recipe egs/wsj/s5/local/chain was used.

## Main scripts

**Data preparation and AM training**

- `run.sh`: prepares the data given as arguments and trains the AM

**Decoding and evaluation**

Based on the AM used for the decoding, a different file needs to be used.

- `compile_decode_gmm.sh`: used to decode the GMM based models (monophone, triphone, triphone LDA, triphone MMI)
- `compile_decode_nnet.sh`: used to decode the NN based models (nnet2, nnet discriminative)
- `uzh/decode_tdnn.sh`: used to decode the TDNN model with iVectors (tdnn)

## Configuration files

`path.sh`: specifies the Kaldi root directory and adds certain directories to the path

`cmd.sh`: selects the way of running parallel jobs

## Folders and files

**Kaldi**

- `archimob`: scripts related to processing the ArchiMob files

- `conf`: configuration files

- `evaluation`: files used for the evaluation

- `local`: original recipe-specific files from egs/wsj/s5

- `steps`: general scripts related to the different steps followed in the Kaldi recipes

- `utils`: utilities shared among all the Kaldi recipes

- `uzh`: secondary scripts not included in the Kaldi recipe

**Resources**

* `data\lexicon`: contains the two PLs compiled in the project

    - `lexicon_zh.txt`: PL built based on the Swiss German Dictionary
    - `lexicon_zh_extended.txt`: PL that was extended by a G2P model trained on the word-pronunciation alignments in `lexicon_zh.txt`

* `data\lms`: contains the Language Models (LM) for Dieth and normalised transcriptions

* `data\mapping`: used to compute FlexWER (not needed for normalised transcriptions)

* `data\splits`: contains the data splits (training, development and testing set)

## Training the ASR model

## Decoding and evaluating a new set