#!/usr/bin/env bash

stage=0
nj=32
test_set="/mnt/lorenz/data/splits/test.csv"
test_affix=test

model_dir="/mnt/lorenz/trainings/norm_baseline/models/ivector"
output_dir="/mnt/lorenz/trainings/norm_baseline/eval/ivector/test"

lm="/mnt/lorenz/data/lms/normalised_80000_open_mkn5.arpa"
lmtype=norm80k

. ./cmd.sh
. ./path.sh
. utils/parse_options.sh

data=${model_dir}/data
exp=${model_dir}/exp
ali_dir=$exp/${gmm}_ali_train_set_sp

nnet3_affix=_online_cmn   # affix for exp dirs, e.g. it was _cleaned in tedlium.
affix=1i   #affix for TDNN+LSTM directory e.g. "1a" or "1b", in case we change the configuration.
dir=$exp/chain${nnet3_affix}/tdnn${affix}_sp
tree_dir=$exp/chain${nnet3_affix}/tree_a_sp

echo
echo "*** Parameters: uzh/decode_tdnn.sh ***"
echo
echo "Set to decode: ${test_set}"
echo "Data affix: ${test_affix}"
echo "Language model: ${lm}"
echo "LM Type: ${lmtype}"
echo "Model path: ${model_dir}"
echo "Output path: ${output_dir}"
echo

# training chunk-options
chunk_width=140,100,160

START_TIME=$(date +%s) # record time of operations


if [ $stage -le 1 ]; then
    echo "$0: creating high-resolution MFCC features"

    utils/copy_data_dir.sh $test_set $data/${test_affix}_set_hires

    steps/make_mfcc.sh --nj $nj --mfcc-config conf/mfcc_hires.conf \
    --cmd "$train_cmd" $data/${test_affix}_set_hires
    steps/compute_cmvn_stats.sh $data/${test_affix}_set_hires
    utils/fix_data_dir.sh $data/${test_affix}_set_hires

fi

if [ $stage -le 2 ]; then
    # Extract iVectors for the test data, but in this case we don't need the speed
    # perturbation (sp).
    nspk=$(wc -l <$data/${test_affix}_set_hires/spk2utt)
    # nspk=133
    steps/online/nnet2/extract_ivectors_online.sh --cmd "$train_cmd" --nj "${nspk}" \
    $data/${test_affix}_set_hires $exp/nnet3${nnet3_affix}/extractor \
    $exp/nnet3${nnet3_affix}/ivectors_${test_affix}_set_hires
fi

if [ $stage -le 3 ]; then
  frames_per_chunk=$(echo $chunk_width | cut -d, -f1)
  rm $dir/.error 2>/dev/null || true

  # Test data
    nspk=$(wc -l <$data/${test_affix}_set_hires/spk2utt)
    # for lmtype in tgpr bd_tgpr; do
    for lmtype in $lmtype; do
      uzh/decode_nnet3_wer_cer.sh \
        --acwt 1.0 --post-decode-acwt 10.0 \
        --extra-left-context 0 --extra-right-context 0 \
        --extra-left-context-initial 0 \
        --extra-right-context-final 0 \
        --frames-per-chunk $frames_per_chunk \
        --nj $nspk --cmd "$decode_cmd"  --num-threads 4 \
        --online-ivector-dir $exp/nnet3${nnet3_affix}/ivectors_${test_affix}_set_hires \
        $tree_dir/graph_${lmtype} \
        $data/${test_affix}_set_hires \
        ${dir}/decode_${lmtype}_${test_affix} || exit 1
    done

fi

mkdir -p $output_dir
cp -r ${dir}/decode_${lmtype}_${test_affix}/scoring_kaldi/. $output_dir


CUR_TIME=$(date +%s)
echo ""
echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
echo ""
echo ""
echo "### DONE: $0 ###"
echo ""