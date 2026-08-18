#youtube ref: https://www.youtube.com/watch?v=iExh0qj2Ouo&list=PLpaxqU9O4beceS4RxsJESmFGUqpw-m2_P&index=4
#IMAGE RECOGNITION AND CLASSIFICATION WITH KERAS IN R

# 1. Setup (run once, then restart R)
install.packages("BiocManager")
BiocManager::install("EBImage")

install.packages("keras")
library(keras)
install_keras()

library(reticulate)
py_install("numpy<2", envname = "r-tensorflow")
use_virtualenv("r-tensorflow", required = TRUE)

# 2. Load images
setwd("C:/Users/Lenovo/Downloads/rlab")
pics <- c('p1.jpg', 'p2.jpg', 'p3.jpg', 'p4.jpg', 'p5.jpg', 'p6.jpg',
          'c1.jpg', 'c2.jpg', 'c3.jpg', 'c4.jpg', 'c5.jpg', 'c6.jpg')

library(EBImage)
mypick <- lapply(pics, readImage)

# 3. Resize and flatten
mypick <- lapply(mypick, function(img) {
  img <- resize(img, w = 28, h = 28)
  array_reshape(img, c(1, 28 * 28 * 3))  # use 784 if grayscale
})

# 4. Train/test split
trainX <- do.call(rbind, mypick[c(1:5, 7:11)])  # 5 planes + 5 cars
testX  <- do.call(rbind, mypick[c(6, 12)])      # 1 plane + 1 car

trainY <- c(rep(0, 5), rep(1, 5))
testY  <- c(0, 1)

trainLabels <- to_categorical(trainY)
testLabels  <- to_categorical(testY)

# 5. Model
model <- keras_model_sequential() %>%
  layer_dense(units = 256, activation = 'relu', input_shape = c(28 * 28 * 3)) %>%
  layer_dense(units = 128, activation = 'relu') %>%
  layer_dense(units = 2, activation = 'softmax')

model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_rmsprop(),
  metrics = 'accuracy'
)

# 6. Train
history <- model %>% fit(
  trainX, trainLabels,
  epochs = 30,
  batch_size = 32,
  validation_split = 0.2
)

# 7. Evaluate
model %>% evaluate(trainX, trainLabels)
model %>% evaluate(testX, testLabels)

# 8. Predict
pred_prob <- model %>% predict(testX)
pred <- apply(pred_prob, 1, which.max) - 1
table(Predicted = pred, Actual = testY)