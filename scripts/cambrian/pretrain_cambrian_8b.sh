#!/bin/bash

export PJRT_DEVICE=TPU &&
export XLA_USE_BF16=0 &&
export HF_DATASETS_CACHE="/mnt/data2/hf_datasets" &&
export HF_HOME="/mnt/data2/hf_cache" &&
export WANDB_RESUME="allow" &&
export CKPT_NAME="amalgam-phi3-pretrain-558k" &&

export CKPT_DIR="/mnt/data2/checkpoints/$CKPT_NAME" &&

python cambrian/train/train_tpu.py \
    --model_name_or_path microsoft/Phi-3-mini-4k-instruct \
    --version v0 \
    --use_dataset True \
    --data_path lmms-lab/LLaVA-ReCap-558K \
    --vision_tower_aux_list '["siglip/CLIP-ViT-SO400M-14-384"]' \
    --vision_tower_aux_token_len_list '[576]' \
    --image_token_len 576 \
    --num_query_group 1 \
    --query_num_list '[576]' \
    --connector_depth 3 \
    --image_position 91 \
    --vision_hidden_size 1024 \
    --connector_only False \
    --num_of_vision_sampler_layers 10 \
    --start_of_vision_sampler_layers 0 \
    --stride_of_vision_sampler_layers 3 \
    --mm_projector_type sva \
    --mm_vision_sampler_lr 1e-4 \
    --tune_mm_mlp_adapter True \
    --mm_vision_select_layer -2 \
    --mm_use_im_start_end False \
    --mm_use_im_patch_token False \
    --image_aspect_ratio pad \
    --bf16 True \
    --output_dir $CKPT_DIR \
    --num_train_epochs 1 \
    --per_device_train_batch_size 2 \
    --per_device_eval_batch_size 1 \
    --gradient_accumulation_steps 1 \
    --evaluation_strategy "no" \
    --save_strategy "steps" \
    --save_steps 1000 \
    --save_total_limit 1 \
    --learning_rate 1e-3 \
    --weight_decay 0. \
    --warmup_ratio 0.06 \
    --lr_scheduler_type "cosine" \
    --logging_steps 1 \
    --tf32 False \
    --model_max_length 2048 \
    --gradient_checkpointing True \
    --dataloader_num_workers 4 \
    --lazy_preprocess True \
    --report_to wandb \
    --run_name $CKPT_NAME \
    --fsdp "full_shard" \
    --fsdp_config fsdp_config.json


CKPT_PATH=/mnt/data2/checkpoints/$CKPT_NAME
# check if the checkpoint path exists
if [ ! -d "$CKPT_PATH" ]; then
    echo "Checkpoint path does not exist. Exiting..."
    # exit 1
fi
echo "Training finished. Syncing checkpoints to GCS..."
#gcloud alpha storage rsync $CKPT_PATH gs://us-central2-storage/cambrian/checkpoints/$CKPT_NAME
#echo "Syncing finished. Checkpoints are now available at gs://us-central2-storage/cambrian/checkpoints/$CKPT_NAME"
