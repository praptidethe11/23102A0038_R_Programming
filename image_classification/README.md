# Image Recognition and Classification with Keras in R

## 1. Project Title

**Image Recognition and Classification with Keras in R**

## 2. Objective

The objective of this project is to implement a simple image recognition and classification system using **R Programming and Keras**.

The model is trained to classify images into two categories:

- **Plane**
- **Car**

The project follows the concepts, procedures, and implementation demonstrated in the prescribed YouTube tutorial provided for Lab Problem 4.

## 3. Problem Description

Image classification is the task of assigning an input image to a predefined category.

In this project, images of planes and cars are processed and given as input to a neural network. The images are resized, converted into numerical arrays, and used to train a classification model.

The trained model is then evaluated using separate test images and used to predict their corresponding classes.

## 4. Reference Video

The implementation is based on the prescribed tutorial:

https://www.youtube.com/watch?v=iExh0qj2Ouo&list=PLpaxqU9O4beceS4RxsJESmFGUqpw-m2_P&index=4

## 5. Dataset

The project uses a small image dataset consisting of **12 images**:

- 6 Plane images: `p1.jpg` to `p6.jpg`
- 6 Car images: `c1.jpg` to `c6.jpg`

### Training Dataset

- 5 Plane images
- 5 Car images
- Total: **10 training images**

### Testing Dataset

- 1 Plane image
- 1 Car image
- Total: **2 testing images**

The dataset size and train/test arrangement follow the prescribed tutorial implementation.

## 6. Technologies and Libraries Used

### Programming Language

- R

### R Libraries

- **Keras** – Used to create, compile, train, and evaluate the neural network.
- **EBImage** – Used for loading and processing images.
- **reticulate** – Used for Python environment integration required by Keras.
- **BiocManager** – Used for installing the EBImage package.

## 7. Project Workflow

The project follows these major steps:

```text
Input Images
     ↓
Load Images using EBImage
     ↓
Resize Images to 28 × 28
     ↓
Convert Images into Numerical Arrays
     ↓
Create Training and Testing Data
     ↓
Create Class Labels
     ↓
Build Keras Neural Network
     ↓
Compile Model
     ↓
Train Model
     ↓
Evaluate Model
     ↓
Predict Test Images
     ↓
Compare Predicted and Actual Classes
```

## 8. Implementation Details

### Step 1: Environment Setup

The required R packages and Python environment are configured using:

- `BiocManager`
- `keras`
- `reticulate`

The required Keras environment is installed and configured before running the project.

### Step 2: Loading Images

The images are loaded using the `readImage()` function from the **EBImage** package.

The project uses:

```text
p1.jpg, p2.jpg, ..., p6.jpg
c1.jpg, c2.jpg, ..., c6.jpg
```

### Step 3: Image Preprocessing

Each image is resized to:

```text
28 × 28
```

The processed image is then reshaped into a numerical vector suitable as input to the neural network.

The model uses:

```text
28 × 28 × 3 = 2352
```

input features for RGB images.

### Step 4: Train/Test Split

The training data consists of:

```text
5 Plane images + 5 Car images
```

The test data consists of:

```text
1 Plane image + 1 Car image
```

### Step 5: Class Labels

The classes are represented numerically:

```text
0 → Plane
1 → Car
```

The labels are converted into categorical form using Keras.

### Step 6: Neural Network Model

A sequential Keras neural network is created with:

- Input layer: 2352 features
- Hidden layer: 256 neurons with ReLU activation
- Hidden layer: 128 neurons with ReLU activation
- Output layer: 2 neurons with Softmax activation

### Step 7: Model Compilation

The model is compiled using:

- **Loss:** Categorical Cross-Entropy
- **Optimizer:** RMSprop
- **Metric:** Accuracy

### Step 8: Model Training

The model is trained using:

- **30 epochs**
- **Batch size:** 32
- **Validation split:** 20%

### Step 9: Evaluation

The trained model is evaluated on:

1. Training data
2. Test data

This provides the loss and accuracy values generated during execution.

### Step 10: Prediction

The trained model predicts the class of the two test images.

The predicted labels are compared with the actual labels using a classification table.

## 9. Expected Output

The project generates:

- Training loss and accuracy
- Validation results during training
- Training dataset evaluation
- Test dataset evaluation
- Predicted classes for the test images
- Comparison of predicted and actual classes

The exact numerical results depend on the execution of the model.

## 10. How to Run the Project

### Prerequisites

Install:

- R / RStudio
- Required R packages
- Python environment required by Keras

### Installation

Run the setup commands provided in the R script to install:

```r
install.packages("BiocManager")
BiocManager::install("EBImage")
install.packages("keras")
```

Then configure the Keras and Python environment using the commands in the R script.

### Dataset Setup

Place all image files in the project directory:

```text
p1.jpg
p2.jpg
p3.jpg
p4.jpg
p5.jpg
p6.jpg

c1.jpg
c2.jpg
c3.jpg
c4.jpg
c5.jpg
c6.jpg
```

Update the `setwd()` path in the R script according to the location of the project on your computer.

### Execute

Open the R script in RStudio and execute the commands sequentially.

The final output displays the model evaluation results and the predicted versus actual classes.

## 11. Project Files

```text
Assignment-4/
│
├── image_classification.R
├── p1.jpg
├── p2.jpg
├── p3.jpg
├── p4.jpg
├── p5.jpg
├── p6.jpg
├── c1.jpg
├── c2.jpg
├── c3.jpg
├── c4.jpg
├── c5.jpg
├── c6.jpg
└── README.md
```

## 12. Result

The project successfully implements an image classification workflow using **R, EBImage, Keras, and a neural network model**.

The trained model is used to classify test images into the two categories:

- Plane
- Car

The final prediction results can be verified using the predicted-versus-actual classification table generated by the R script.

## 13. Conclusion

This project demonstrates the practical implementation of image recognition and classification using R and Keras. It covers image loading, preprocessing, dataset preparation, neural network construction, model training, evaluation, and prediction.

The project also follows the laboratory requirement of organizing the implementation as a project and maintaining it using Git and GitHub.

## 14. Git and GitHub

The project is maintained using Git for version control.

Meaningful commits are used to document different stages of development, such as:

```text
Initial project setup
Added image dataset
Implemented image preprocessing
Added Keras classification model
Added training and evaluation
Added prediction functionality
Added README and screenshots
```

The completed project is published on GitHub.

### GitHub Repository

**Repository Link:**  
`https://github.com/praptidethe11/Image-classification-with-Keras-in-R`

---

## 15. Academic Information

**Course:** R Programming  
**Laboratory Problem:** 4 – R Project Implementation and Version Control Using GitHub  
**Primary Course Outcome:** CO6  
**Additional Course Outcome:** CO3

The assignment focuses on implementing an end-to-end R-based project, testing the implementation, documenting the work, and maintaining the project using Git and GitHub.
