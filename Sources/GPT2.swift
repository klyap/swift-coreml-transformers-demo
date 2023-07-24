//
//  GPT2.swift
//  CoreMLGPT2
//
//  Created by Julien Chaumond on 19/07/2019.
//  Copyright © 2019 Hugging Face. All rights reserved.
//

import Foundation
import CoreML


@available(iOS 15.0, *)
class GPT2 {
    
    enum DecodingStrategy {
        /// At each time step, we select the most likely next token
        case greedy
        /// Sample only from the top-k most-probable tokens (k is a hyper-parameter).
        case topK(Int)
        /// Sample from the top tokens with a cumulative probability just above a threshold (nucleus/top-p).
        case topP(Double)
    }
    
    private let model: float32_model
    public let tokenizer = GPT2Tokenizer()
    public let seqLen = 128
    private let strategy: DecodingStrategy
    
    init(strategy: DecodingStrategy = .greedy) {
        self.strategy = strategy
        
        var llmModel: float32_model {

            do {

            print("initializing model");

            return try float32_model(configuration: .init())

            } catch {

            fatalError("Couldn't load LLM model due to: \(error.localizedDescription)")

            }

        }

        self.model = llmModel
    }
    
    /// Main prediction loop:
    /// Predict next token from array of previous tokens.
    /// - featurization
    /// - model inference
    /// - Decoding according to the model's `strategy`
    func predict(tokens: [Int]) -> Int {
        /// Truncate tokens if they are too long
        let maxTokens = (tokens.count > seqLen)
            ? Array(tokens[..<seqLen])
            : tokens
        
        /// Pad input_ids on the right, up to `seqLen`:
//        let input_ids = MLMultiArray.from(
//            maxTokens + Array(repeating: 0, count: seqLen - maxTokens.count)
//        )
        let input_ids = try! MLMultiArray(shape: [1, NSNumber(value: seqLen)], dataType: .int32)
        let attention_masks = try! MLMultiArray(shape: [1, NSNumber(value: seqLen)], dataType: .int32)

        for i in 0..<seqLen {
            input_ids[[0, i] as [NSNumber]] = (i < maxTokens.count ? maxTokens[i] : 0) as NSNumber
            attention_masks[[0, i] as [NSNumber]] = (i < maxTokens.count ? 1 : 0) as NSNumber
        }
        
//        let position_ids = MLMultiArray.from(
//            Array(0..<seqLen)
//        )
//        let position_ids = MLMultiArray.from(
//            Array(Array(0..<seqLen)))
//        print("position_ids", position_ids);

        /// A masking matrix (logits). It has zero values in the first X number of columns, where X = number of input tokens without the padding,and value -1e+4 in the remaining 384-X (padding) columns.
//        let attention_mask = try! MLMultiArray(shape: [1, 1, NSNumber(value: seqLen), NSNumber(value: seqLen)], dataType: .float32)
//        for i in 0..<seqLen {
//            for j in 0..<seqLen {
//                attention_mask[[0, 0, i, j] as [NSNumber]] = (j < tokens.count + tokens.count + 3) ? 0 : -1_000
//            }
//        }
        
        let output = try! model.prediction(input_ids: input_ids, attention_mask: attention_masks)
        print("--------output", output);
        print("--------output.token_scores",  output.token_scores);

        let outputLogits = MLMultiArray.slice(
            output.token_scores,
            indexing: [.select(0), .select(maxTokens.count - 1), .slice]
        )
//        let outputLogits = output.token_scores;
        
        print("--------outputLogits",  outputLogits)

        switch strategy {
        case .greedy:
            let nextToken = Math.argmax(outputLogits)
            print("------argmax nextToken", nextToken)
            return nextToken.0
        case .topK(let k):
//            func toDoubleArray(_ o: MLMultiArray) -> [Float32] {
//                var arr: [Float32] = Array(repeating: 0, count: o.count)
//                let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(o.dataPointer))
//                for i in 0..<o.count {
//                    arr[i] = Float32(ptr[i])
//                }
//                return arr
//            }
            let logits = MLMultiArray.toDoubleArray(outputLogits)
            let topk = Math.topK(arr: logits, k: k)
//            let topk = Math.topKFloat32(arr: logits, k: k)
            let sampleIndex = Math.sample(indexes: topk.indexes, probs: topk.probs)
            return sampleIndex
        case .topP(_):
            fatalError("topP is not implemented yet")
        }
    }
    
    
    /// Main generation loop.
    ///
    /// Will generate next `nTokens` (defaults to 10).
    /// Calls an incremental `callback` for each new token, then returns the generated string at the end.
    ///
    func generate(text: String, nTokens: Int = 10, callback: ((String, Double) -> Void)?) -> String {
        var tokens = tokenizer.encode(text: text)
        var newTokens: [Int] = []
        for i in 0..<nTokens {
            let (nextToken, time) = Utils.time {
                print("----------tokens", tokens)
                return predict(tokens: tokens)
            }
            
            tokens.append(nextToken)
            newTokens.append(nextToken)
            print("🦄 <\(time)s>", i, nextToken, tokens.count)
            callback?(
                tokenizer.decode(tokens: newTokens), time
            )
        }
        return tokenizer.decode(tokens: newTokens)
    }
}
