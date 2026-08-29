# ============================================================

# IMAGE RECOGNITION & CLASSIFICATION WITH KERAS IN R

# Plane vs Car Classification

# Based on the experiment by Dr. Bharatendra Rai

# ============================================================

# ============================================================

# 1. LOAD PACKAGES

# ============================================================

library(EBImage)
library(keras3)

# Use TensorFlow as the backend

use_backend("tensorflow")

# ============================================================

# 2. SET WORKING DIRECTORY

# ============================================================


setwd("data")

# Check working directory

getwd()

# Check available files

list.files()

# ============================================================

# 3. DEFINE IMAGE FILES

# ============================================================

pics <- file.path(
  "data",
  c(
    "p1.jpg",
    "p2.jpg",
    "p3.jpg",
    "p4.jpg",
    "p5.jpg",
    "p6.jpg",
    "c1.jpg",
    "c2.jpg",
    "c3.jpg",
    "c4.jpg",
    "c5.jpg",
    "c6.jpg"
  )
)

# Check whether all files exist

file.exists(pics)

# ============================================================

# 4. READ IMAGES

# ============================================================

mypic <- list()

for (i in 1:length(pics)) {
  cat("\nTrying:", pics[i], "\n")
  
  tryCatch(
    {
      img <- readImage(pics[i])
      cat("SUCCESS\n")
    },
    error = function(e) {
      cat("ERROR:", conditionMessage(e), "\n")
    }
  )
}

# Check image structure

str(mypic)

mypic <- list()

for (i in 1:length(pics)) {
  mypic[[i]] <- readImage(pics[i])
}

length(mypic)

str(mypic)
display(mypic[[1]])
display(mypic[[8]])
# ============================================================

# 5. EXPLORE THE IMAGES

# ============================================================

# Display first image

display(mypic[[1]])

# Display one of the car images

display(mypic[[8]])

# Print image information

print(mypic[[1]])

# Summary

summary(mypic[[1]])

# Histogram

hist(mypic[[2]])

# Structure

str(mypic)

# ============================================================

# 6. DISPLAY ALL ORIGINAL IMAGES

# ============================================================

par(mfrow = c(3, 4))

for (i in 1:length(mypic)) {
  plot(mypic[[i]])
}

par(mfrow = c(1, 1))

# ============================================================

# 7. RESIZE ALL IMAGES

# ============================================================

# Resize every image to 28 x 28 pixels

for (i in 1:length(mypic)) {
  mypic[[i]] <- resize(mypic[[i]], 28, 28)
}

# Check structure

str(mypic)

# ============================================================

# 8. RESHAPE IMAGES

# ============================================================

# Each image is:

# 28 x 28 x 3

#

# 28 * 28 * 3 = 2352

#

# Therefore each image becomes a vector of 2352 values.

for (i in 1:length(mypic)) {
  mypic[[i]] <- array_reshape(
    mypic[[i]],
    c(28, 28, 3)
  )
}

# Check structure

str(mypic)

# Number of input features

28 * 28 * 3

# ============================================================

# 9. CREATE TRAINING DATA

# ============================================================

# Images:

#

# p1-p5 = training planes

# p6    = testing plane

#

# c1-c5 = training cars

# c6    = testing car

#

# Original experiment uses:

# p1-p5 + c1-c5 for training

# p6 + c6 for testing

trainx <- NULL

# Plane training images

for (i in 1:5) {
  trainx <- rbind(trainx, mypic[[i]])
}

# Car training images

for (i in 7:11) {
  trainx <- rbind(trainx, mypic[[i]])
}

# Check training data

str(trainx)

dim(trainx)

# ============================================================

# 10. CREATE TEST DATA

# ============================================================

testx <- rbind(
  mypic[[6]],
  mypic[[12]]
)

# Check test data

str(testx)

dim(testx)

# ============================================================

# 11. CREATE CLASS LABELS

# ============================================================

# Class encoding:

#

# 0 = Plane

# 1 = Car

trainy <- c(
  0, 0, 0, 0, 0,
  1, 1, 1, 1, 1
)

testy <- c(
  0, 1
)

# Check labels

trainy
testy

# ============================================================

# 12. ONE-HOT ENCODING

# ============================================================

trainLabels <- to_categorical(trainy)

testLabels <- to_categorical(testy)

# Display encoded labels

trainLabels
testLabels

# ============================================================

# 13. BUILD NEURAL NETWORK

# ============================================================

model <- keras_model_sequential(
  input_shape = c(2352)
) |>
  layer_dense(
    units = 256,
    activation = "relu"
  ) |>
  layer_dense(
    units = 128,
    activation = "relu"
  ) |>
  layer_dense(
    units = 2,
    activation = "softmax"
  )


rm(model)

# ============================================================

# 14. DISPLAY MODEL SUMMARY

# ============================================================

summary(model)

# ============================================================

# 15. COMPILE MODEL

# ============================================================

model |> compile(
  loss = "categorical_crossentropy",
  optimizer = optimizer_rmsprop(),
  metrics = "accuracy"
)

# ============================================================

# 16. TRAIN MODEL

# ============================================================

history <- model |> fit(
  trainx,
  trainLabels,
  epochs = 30,
  batch_size = 32,
  validation_split = 0.2
)

# ============================================================

# 17. PLOT TRAINING HISTORY

# ============================================================

plot(history)

# ============================================================

# 18. EVALUATE MODEL ON TRAINING DATA

# ============================================================

train_result <- model |> evaluate(
  trainx,
  trainLabels
)

print(train_result)

# ============================================================

# 19. PREDICT TRAINING DATA

# ============================================================

train_prob <- predict(
  model,
  trainx
)

# Convert probabilities into predicted class

train_pred <- max.col(train_prob) - 1

# Display predictions

train_pred

# Compare prediction with actual labels

table(
  Predicted = train_pred,
  Actual = trainy
)

# ============================================================

# 20. DISPLAY TRAINING PREDICTION PROBABILITIES

# ============================================================

train_results <- cbind(
  Plane_Probability = train_prob[, 1],
  Car_Probability = train_prob[, 2],
  Predicted = train_pred,
  Actual = trainy
)

print(train_results)

# ============================================================

# 21. EVALUATE MODEL ON TEST DATA

# ============================================================

test_result <- model |> evaluate(
  testx,
  testLabels
)

print(test_result)

# ============================================================

# 22. PREDICT TEST DATA

# ============================================================

test_prob <- predict(
  model,
  testx
)

# Convert probabilities into class

test_pred <- max.col(test_prob) - 1

# Display predictions

test_pred

# ============================================================

# 23. TEST CONFUSION MATRIX

# ============================================================

table(
  Predicted = test_pred,
  Actual = testy
)

# ============================================================

# 24. DISPLAY TEST PROBABILITIES

# ============================================================

test_results <- cbind(
  Plane_Probability = test_prob[, 1],
  Car_Probability = test_prob[, 2],
  Predicted = test_pred,
  Actual = testy
)

print(test_results)

# ============================================================

# 25. DISPLAY HUMAN-READABLE PREDICTIONS

# ============================================================

class_names <- c(
  "Plane",
  "Car"
)

predicted_names <- class_names[test_pred + 1]
actual_names <- class_names[testy + 1]

final_results <- data.frame(
  Image = c("p6.jpg", "c6.jpg"),
  Predicted = predicted_names,
  Actual = actual_names,
  Plane_Probability = round(test_prob[, 1], 4),
  Car_Probability = round(test_prob[, 2], 4)
)

print(final_results)

# ============================================================

# 26. CALCULATE TEST ACCURACY MANUALLY

# ============================================================

test_accuracy <- mean(
  test_pred == testy
)

cat(
  "Test Accuracy:",
  round(test_accuracy * 100, 2),
  "%\n"
)

# ============================================================

# 27. SAVE THE TRAINED MODEL

# ============================================================

save_model(
  model,
  "plane_car_model.keras"
)

cat("Model saved successfully.\n")

# ============================================================

# END OF EXPERIMENT

# ============================================================
