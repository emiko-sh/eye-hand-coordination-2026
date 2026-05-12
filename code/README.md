
## Eye-Hand Coordination Analysis (Tracing Task)  
Shishido, E. (2026). Beyond Expertise: Stable Individual Differences in Predictive Eye–Hand Coordination. arXiv:2602.07816. https://arxiv.org/abs/2602.07816

This repository contains MATLAB source code for analyzing eye-hand coordination during drawing (tracing) tasks, using data from Tobii eye trackers and pen tablets.  

## Overview
The program quantifies the relationship between gaze and pen position, calculating metrics such as "Gaze Precedence" (Time/Point) and movement velocity to understand how the gaze guides or follows the hand.

The algorithms are based on the research by Yamasaki et al. (2015), focusing on extracting features of gaze and pen movement, including saccades, fixations, and pursuit movements.

Reference
Yamasaki, K., Itoh, T., Itoh, Y., Okazaki, S., Sadato, N., Imoto, K., Shishido, E., and Fukumura, N. (2015).
Feature extraction of eye-hand coordination in tracing tasks of calligraphers.
IEICE Tech. Rep., vol. 114, no. 515, NC2014-123, pp. 313–318.

## Key Features
Data Preprocessing & Coordinate Transformation

Converts pixel coordinates from Tobii and pen tablets into real-world dimensions (mm) based on monitor resolution and aspect ratio.

Applies a 5-point moving average to smooth pen data.

Trajectory Matching

Calculates the minimum distance between measured positions (gaze/pen) and the theoretical target trajectory (ModelTrajectory_new0803.mat).

Gaze Movement Classification

Saccade: Detected based on a velocity threshold (approx. 310 mm/s) and displacement.

Fixation / Pursuit: Classified using the ratio of gaze velocity to pen velocity (ratio ≤ 0.4).

Metric Calculation

Time Precedence: The lead time of the gaze relative to the pen's current position on the trajectory.

Point Precedence: The distance gap between gaze and pen along the target path.

Curvature Analysis: Computes velocity, acceleration, and curvature (1/R) of the target line (curvature.m).

File Structure
script.m: Main analysis script (contains core logic for coordinate conversion, classification, and precedence calculation).

curvature.m: Function to calculate velocity, acceleration, and curvature from X-Y coordinates.

ModelTrajectory_new0803.mat: Theoretical target trajectory data used as a baseline.

sample_data/: Contains sample Tobii (TSV) and pen data.

Technical Notes & Troubleshooting
Important: Script Completion Required
The provided script.m contains code snippets and will not run out-of-the-box. To make it functional, you must define or load the following variables before execution:

Input Data: Ensure variables like GazePointX, GazePointY, PenX, PenY, Pentime, and Timestamp are loaded from your data files.

Indexing: Define data_start and data_end to specify the analysis window.

Parameters: Set GifName (e.g., 'L1-1') to match the switch-case logic for loading the correct theoretical trajectory.

Customization
Screen Calibration: Adjust the scaling factors (e.g., 0.318, 0.316) in script.m and curvature.m to match your specific display's physical size and resolution.

Thresholds: Saccade detection thresholds (velocity/distance) may need tuning depending on your sampling rate and task difficulty.

## Citation
If you use this dataset or code, please cite my paper:  
Shishido, E. (2026). Beyond Expertise: Stable Individual Differences in Predictive Eye–Hand Coordination. arXiv:2602.07816. https://arxiv.org/abs/2602.07816

# 日本語　Japanese
Eye-Hand Coordination Analysis (Tracing Task)
このリポジトリは、Tobiiアイトラッカーとペンタブレットを用いて計測された、描画タスク（なぞり書き）中の視線とペンの動きを解析するためのMATLABソースコードです。

本プログラムは、信学会技術研究報告（NC2014-123） に掲載された、山崎ら (2015) の手法に基づき、視線とペンの位置関係やサッカード、固視、追従運動の抽出を行います。

概要
描画時における「視線の先行（Gaze Precedence）」や「運動速度」を計算し、視線がどのようにペンをガイドしているか、あるいは追従しているかを定量化します。

参考文献
山崎 恭平, 伊藤 忠博, 伊藤 嘉浩, 岡崎 善弘, 定藤 規弘, 井本 桂右, 宍戸 絵里香, 福村 直博 (2015).
運筆課題における目と手の協調動作の特徴抽出.
信学技報, vol. 114, no. 515, NC2014-123, pp. 313-318.

主な機能
データの前処理と座標変換

Tobii（視線）とペンタブレットのピクセル座標を、モニターの解像度・アスペクト比に基づき実寸法（mm）に変換。

ペンデータの移動平均（5点）による平滑化。

理論軌道との照合

計測された視線・ペンの位置と、理論上のターゲット軌道（ModelTrajectory_new0803.mat）との最短距離を算出。

視線運動の分類（Saccade / Fixation / Pursuit）

Saccade（サッカード）: 視線速度閾値（約310 mm/s以上）および移動距離による判定。

Fixation / Pursuit（固視・追従）: ペン速度と視線速度の比率（0.4以下を固視/追従と判定）を用いた分類。

指標の算出

Time Precedence: 視線がペンの現在位置に到達するまでの時間先行量。

Point Precedence: 視線とペンのターゲット軌道上の距離差。

Curvature（曲率）: 理論軌道の曲率算出（curvature.m）。

ファイル構成
script.m: メイン解析スクリプト。データの読み込み、座標変換、運動分類、先行量の計算を行います。

curvature.m: ターゲット軌道のx, y座標から、速度、加速度、および曲率（半径の逆数）を算出する関数。

ModelTrajectory_new0803.mat: 比較対象となる理論的なターゲット軌道データ。

sample_data/: Tobiiおよびペン入力のサンプルデータ（TSV形式など）。

## 参照
Shishido, E. (2026). Beyond Expertise: Stable Individual Differences in Predictive Eye–Hand Coordination. arXiv:2602.07816. https://arxiv.org/abs/2602.07816
