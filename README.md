
# Swift Core ML implementations of Transformers: TinyStories-1M and other GPT2-like models

This repo has the code for an iOS app runnning a LLM model that uses GPT2 tokenizer on-device

## Quickstart
Just replace the `float32_model` file with your own model exported from [HuggingFace Transformers to CoreML space](https://huggingface.co/spaces/huggingface-projects/transformers-to-coreml)

[More detailed guide](https://hickory-scissor-277.notion.site/CoreML-Sample-iOS-App-e54cd2492d9c4011b96d069f2bc35d31?pvs=4)


## Contents
This repository contains:
- For **models that use GPT-2 tokenization**:
	- The [GPT-2 generation model](https://github.com/huggingface/swift-coreml-transformers/blob/master/Sources/GPT2.swift) itself, including decoding strategies (greedy and TopK are currently implemented) and GPT-2 Byte-pair encoder and decoder.
   	- [TinyStories-1M model](https://huggingface.co/roneneldan/TinyStories-1M/tree/main) in CoreML format
	- A neat demo app showcasing on-device text generation.

This repository also contains, from the original repo:
- For **BERT** and **DistilBERT**:
	- pretrained [Google BERT](https://github.com/google-research/bert) and [Hugging Face DistilBERT](https://arxiv.org/abs/1910.01108) models fine-tuned for Question answering on the SQuAD dataset.
	- Swift implementations of the [BERT tokenizer](https://github.com/huggingface/swift-coreml-transformers/blob/master/Sources/BertTokenizer.swift) (`BasicTokenizer` and `WordpieceTokenizer`) and SQuAD dataset parsing utilities.
	- A neat demo question answering app.

- For **GPT-2** and **DistilGPT-2**:
	- a [conversion script](https://github.com/huggingface/swift-coreml-transformers/blob/master/model_generation/gpt2.py) from PyTorch trained GPT-2 models (see our [`transformers`](https://github.com/huggingface/transformers) repo) to CoreML models.


# 🦄 Demo

Unleash the full power of text generation with GPT-2 on device!!

![demo](https://raw.githubusercontent.com/huggingface/swift-coreml-transformers/master/media/coreml-gpt2.gif)


## Notes

We use `git-lfs` to store large model files and it is required to obtain some of the files the app needs to run.
See how to install `git-lfs`on the [installation page](https://git-lfs.github.com/)

