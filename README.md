# Master's thesis on Pronunciation Lexicon in Swiss German ASR

## Description

This repository contains the Kaldi recipe and data used to train Swiss German ASR systems in the course of the Master's thesis in 2020. The main focus was on the Pronunciation Lexicon (PL) which is compiled based on the [_Swiss German Dictionary_](https://www.spur.uzh.ch/en/departments/research/textgroup/Swisscom-s-Swiss-German-Dictionary.html). I investigated how the PL can be extended with Grapheme-to-Phoneme (G2P) conversion. Furthermore, I looked at how it impacts the performance of the ASR model when using different PLs at the two stages within the ASR system: training of the Acoustic Model (AM) and decoding.

The following sections describe how the Kaldi framework is structured and how to use the code to train, decode and evaluate an ASR model.

The Kaldi (version 5.5) recipe egs/wsj/s5 (commit 8cc5c8b32a49f8d963702c6be681dcf5a55eeb2e) was used as a reference. For the TDNN acoustic model, the recipe egs/wsj/s5/local/chain was used.

## Main scripts

**Data preparation and AM training**

`run.sh`: 

**Decoding and evaluation**

Based on the AM used for the decoding, a different file needs to be used.

`compile_decode_gmm.sh`:
`compile_decode_nnet.sh`:
`uzh/decode_tdnn.sh`:

## Configuration

## Folders

## Training the ASR model

## Decoding and evaluating a new set