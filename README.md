# Master's thesis on Pronunciation Lexicon in Swiss German ASR

## Description

This repository contains the Kaldi recipe and data used to train Swiss German ASR systems in the course of the Master's thesis in 2020. The main focus was on the Pronunciation Lexicon (PL) which is compiled based on the [_Swiss German Dictionary_](https://www.spur.uzh.ch/en/departments/research/textgroup/Swisscom-s-Swiss-German-Dictionary.html). I investigated how the PL can be extended with Grapheme-to-Phoneme (G2P) conversion. Furthermore, I looked at how it impacts the performance of the ASR model when using different PLs at the two stages within the ASR system: training of the Acoustic Model (AM) and decoding.

The following sections describe how the Kaldi framework is structured and how to use the code to train, decode and evaluate an ASR model.

The Kaldi (version 5.5) recipe egs/wsj/s5 (commit 8cc5c8b32a49f8d963702c6be681dcf5a55eeb2e) was used as a reference. For the TDNN acoustic model, the recipe egs/wsj/s5/local/chain was used.

## Main scripts

**Data preparation and AM training**

- `run.sh`: prepares the data given as arguments and trains the AM

```
run.sh <archimob_input_csv> <archimob_wav_files_directory> <am_output_directory> <transcription_type> <pronunciation_lexicon> (<lang_folder_from_decoded_set>)
```

**Decoding and evaluation**

Based on the AM used for the decoding, a different file needs to be used.

- `compile_decode_gmm.sh`: used to decode the GMM based models (monophone, triphone, triphone LDA, triphone MMI)
- `compile_decode_nnet.sh`: used to decode the NN based models (nnet2, nnet discriminative)
- `uzh/decode_tdnn.sh`: used to decode the TDNN model with iVectors (tdnn)

```
compile_decode_norm_gmm.sh <lm> <am_output_directory> <specific_am_directory> <archimob_set_to_decode> <archimob_wav_files_directory> <eval_output_directory> <transcription_type> <pronunciation_lexicon>
```

```
compile_decode_nnet.sh <lm> <am_output_directory> <specific_am_directory> <archimob_set_to_decode> <archimob_wav_files_directory> <eval_output_directory> <transcription_type> <pronunciation_lexicon>
```

```
uzh/decode_tdnn.sh --test-set <archimob_set_to_decode> --test_affix <set_affix> --lm <lm> --lmtype <lm_affix> --model-dir <specific_am_directory> --output-dir <eval_output_directory>
```

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

* `data/lexicon`: contains the two PLs compiled in the project

    - `lexicon_zh.txt`: PL built based on the Swiss German Dictionary
    - `lexicon_zh_extended.txt`: PL that was extended by a G2P model trained on the word-pronunciation alignments in `lexicon_zh.txt`

* `data/lms`: contains the Language Models (LM) for Dieth and normalised transcriptions

* `data/mapping`: used to compute FlexWER (not needed for normalised transcriptions)

* `data/splits`: contains the data splits (training, development and testing set)

## Training the ASR model

The following steps can be executed to train the AM:

```
nohup ./run.sh \
      data/splits/train.csv \
      data/archimob_r2/chunked_wav_files \
      output_dir_model \
      "norm" \
      data/lexicon/lexicon_zh_extended.txt
```

The file `run.sh` contains a number of options that can be controlled. This includes the data preparation and the feature extraction, which both only need to be done once for a given `output_dir_model` folder. Set the following values to "1" to perform these actions:

- `do_archimob_preparation=1`
- `do_data_preparation=1`
- `do_feature_extraction=1`

These options are followed by the AM type that you want to train. The four GMM based models (monophone, triphone, triphone_lda and triphone_mmi) are built on top of each other and need to be executed consecutively. Also, the NN based models (nnet and nnet_discriminative) and the TDNN model (tdnn) need to be built on top of a previous model (preferably triphone_mmi).

- `do_train_monophone=1`
- `do_train_triphone=1`
- `do_train_triphone_lda=1`
- `do_train_mmi=1`
- `do_nnet2=1`
- `do_nnet2_discriminative=1`
- `do_train_tdnn=0`

Training the TDNN model needs the lang folder of a decoded set as an additional argument to extract the iVectors from:

```
nohup ./run.sh \
      data/splits/train.csv \
      data/archimob_r2/chunked_wav_files \
      output_dir_model \
      "norm" \
      data/lexicon/lexicon_zh_extended.txt \
      output_dir_model/eval/tri_mmi/dev/lang
```

## Decoding and evaluating a new set

The compilation of the WFST graph, the decoding and evaluation is done based on the AM type. There are three different files.

**Decoding with GMM based models**

```
nohup ./compile_decode_gmm.sh \
      data/lms/normalised_80000_open_mkn5.arpa \
      output_dir_model \
      output_dir_model/models/tri_mmi \
      data/splits/normalised_dev.csv \
      data/archimob_r2/chunked_wav_files \
      output_dir_model/eval/tri_mmi/dev \
      "norm" \
      data/lexicon/lexicon_zh_extended.txt
```

**Decoding with NN based models**

```
nohup ./compile_decode_nnet.sh \
      data/lms/normalised_80000_open_mkn5.arpa \
      output_dir_model \
      output_dir_model/models/tri_mmi \
      data/splits/normalised_dev.csv \
      data/archimob_r2/chunked_wav_files \
      output_dir_model/eval/tri_mmi/dev \
      "norm" \
      data/lexicon/lexicon_zh_extended.txt
```

**Decoding with TDNN model**

```
nohup uzh/decode_tdnn.sh \
      --test-set "data/splits/normalised_dev.csv" \
      --test_affix "dev" \
      --lm "data/lms/normalised_80000_open_mkn5.arpa" \
      --lmtype "norm80k" \
      --model-dir "output_dir_model/models/ivector" \
      --output-dir "output_dir_model/eval/ivector/dev"
```