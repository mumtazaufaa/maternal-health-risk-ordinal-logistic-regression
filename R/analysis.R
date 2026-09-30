# ======================================================================
# Import Libraries
# ======================================================================
library(MASS)
library(ggplot2)
library(dplyr)
library(corrplot)
library(GGally)
library(tidyr)
library(caret)

# ======================================================================
# Read Data & Data Preprocessing
# ======================================================================

df <- read.csv("Maternal Health Risk Data Set.csv")
View(df)
df

library(car)

nrow(df)
colnames(df)

sum(is.na(df))
# There is no missing value

print_boxplot <- function(df){
  numeric_df <- df[, sapply(df, is.numeric)]
  dev.new(width = 12, height = 8)
  boxplot(numeric_df,
          xlab = "Variable",
          ylab = "Value",
          las = 2,
          col = rainbow(ncol(numeric_df)))
}

print_boxplot(df)

# Tukey method to remove outliers
replace_outliers <- function(x, k = 1.5) {
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR_value <- Q3 - Q1
  lower <- Q1 - k * IQR_value
  upper <- Q3 + k * IQR_value
  x[x < lower] <- lower
  x[x > upper] <- upper
  return(x)
}

df_clean <- df %>%
  mutate_at(vars(Age, SystolicBP, DiastolicBP, BS, BodyTemp, HeartRate), replace_outliers)

print_boxplot(df_clean)

# Ordinal factor the target variable
unique(df_clean$RiskLevel)

str(df_clean$RiskLevel)
df_clean$RiskLevel <- factor(df_clean$RiskLevel,
                             levels = c("low risk", "mid risk", "high risk"),
                             ordered = TRUE)
str(df_clean$RiskLevel)

# ======================================================================
# Model Training
# ======================================================================

model_0 = polr(RiskLevel ~ 1, data = df_clean, Hess = TRUE, method = "logistic")
summary(model_0)

model_logistic <- polr(RiskLevel ~ Age + SystolicBP + DiastolicBP + BS + BodyTemp + HeartRate, data = df_clean, Hess = TRUE, method = "logistic")
summary(model_logistic)

# ======================================================================
# Variables Exploration
# ======================================================================
model_summary <- coef(summary(model_logistic))
View(model_summary)
model_summary

pwald <- pnorm(abs(model_summary[, "t value"]), lower.tail = FALSE) * 2
ctable <- cbind(model_summary, 
                "p value" =  pwald, 
                "Is Significant?" = ifelse(pwald > 0.05, "no", "yes"),
                "Odds Ratio" = exp(model_summary[, "Value"]))
View(ctable)
ctable

# ======================================================================
# Exploratory Data Analysis
# ======================================================================

# Likelihood Ratio Test
# Ho: B1 = B2 = ... = Bk = 0
anova(model_0, model_logistic, test="Chisq")

# 1. Histogram for every numerical variables
numeric_vars <- df_clean %>% select(Age, SystolicBP, DiastolicBP, BS, BodyTemp, HeartRate)

numeric_vars %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Value") %>%
  ggplot(aes(x = Value)) +
  facet_wrap(~ Variable, scales = "free", ncol = 3) +
  geom_histogram(fill = "steelblue", color = "black", bins = 30) +
  theme_minimal() +
  labs(title = "Distribution of Predictors", x = "Value", y = "Frequency")

# 2. Correlation between variables
cor_mat <- cor(numeric_vars)
corrplot(cor_mat, method = "color", type = "upper", tl.col = "black", tl.srt = 45, addCoef.col = "black")

# 3. Boxplot of predictors based on RiskLevel
numeric_vars$RiskLevel <- df_clean$RiskLevel
numeric_vars_long <- numeric_vars %>%
  pivot_longer(-RiskLevel, names_to = "Variable", values_to = "Value")

ggplot(numeric_vars_long, aes(x = RiskLevel, y = Value, fill = RiskLevel)) +
  geom_boxplot() +
  facet_wrap(~ Variable, scales = "free", ncol = 3) +
  theme_minimal() +
  labs(x = "Risk Level", y = "Value") +
  theme(legend.position = "none")

# 4. Density plot to determine variable's distribution based on RiskLevel
ggplot(numeric_vars_long, aes(x = Value, color = RiskLevel, fill = RiskLevel)) +
  geom_density(alpha = 0.4) +
  facet_wrap(~ Variable, scales = "free", ncol = 3) +
  theme_minimal() +
  labs(title = "Density Plot Based-on RiskLevel", x = "Value", y = "Density")

# 5. Pairplot (gunakan GGally)
ggpairs(df_clean,
        columns = c("Age", "SystolicBP", "DiastolicBP", "BS", "BodyTemp", "HeartRate"),
        aes(color = RiskLevel, alpha = 0.6)) +
  theme_bw()


# ======================================================================
# Model Eval
# ======================================================================


# 1. Predict on df_clean
# (Type = "class" gives the most probable ordered factor)
predictions <- predict(model_logistic, data = df_clean, type = "class")


# 2. Confusion Matrix and detailed stats
cm <- confusionMatrix(predictions, df_clean$RiskLevel)
cm$overall

print(cm)

# 3. Extract key metrics
accuracy   <- cm$overall["Accuracy"]
kappa      <- cm$overall["Kappa"]
# By-class stats: Sensitivity, Specificity, Precision, etc.
per_class  <- cm$byClass

cat("Accuracy:", round(accuracy, 4), "\n")
cat("Cohen's Kappa:", round(kappa, 4), "\n")
print(per_class[, c("Sensitivity", "Specificity", "Precision", "F1", "Balanced Accuracy")])

# 4. Pseudo R-squared (McFadden's)
# Requires log-likelihoods from your model
ll_full   <- logLik(model_logistic)
ll_null   <- logLik(model_0)
mcfadden  <- 1 - as.numeric(ll_full / ll_null)
cat("McFadden pseudo-R²:", round(mcfadden, 4), "\n")

