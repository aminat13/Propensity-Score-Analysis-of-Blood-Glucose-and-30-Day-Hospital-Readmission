#loading required packages 
library(readmission)
library(ggplot2)
library(dplyr)
library(knitr)
library(kableExtra)
library(tidyverse)
library(broom)
library(forcats)
library(gtsummary)

#exploring data strucure
data(readmission)
str(readmission)
summary(readmission)
attach(df)

#creating outcome distribution chart 
table(readmission$readmitted)
prop.table(table(readmission$readmitted))

b_plot<- ggplot(readmission, aes(x = readmitted, fill = readmitted)) +
  geom_bar() +
  geom_text(stat = "count", aes(label = scales::comma(after_stat(count))), 
            vjust = -0.5, size = 3) +
  scale_fill_manual(values = c("No" = "#0D7377", "Yes" = "#C0392B")) +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.1))) +
  labs(subtitle = paste("n =", scales::comma(nrow(readmission)), "diabetic inpatient encounters"),
       x = "Readmitted within 30 days",
       y = "Count") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold"),
        panel.grid.major.x = element_blank())

print(b_plot) 

###TASK 1: 

#filtering df to include normal and high values only and dropping NAs
df <- readmission %>%
filter(!is.na(blood_glucose),
         blood_glucose %in% c("High", "Normal")) %>%

#converting all NA categorical variables into missing 
mutate(
  across(
    where(~ is.character(.x) | is.factor(.x)),
     ~ fct_explicit_na(factor(.x), na_level = "Missing")
  )
)
colSums(is.na(df))

dim(readmission)
dim(df)

#fitting crude logistic regression 
model_1 <- glm(readmitted ~ blood_glucose, data = df, family = binomial)
summary(model_1)  

#calculating OR and 95%CI
crude_or <-exp(cbind(OR = coef(model_1),confint(model_1))) 

###TASK 2: 

#creating comparison table 
table1 <- df %>%
  select(-readmitted) %>%
  tbl_summary(
    by = blood_glucose,
    statistic = list(
      all_continuous() ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    missing = "ifany"
  ) %>%
  bold_labels()
table1

#generating categorical p values
cat_vars <- c("race","sex","age","admission_source","insurer")
p_cat <- sapply(cat_vars, function(v) {
  tab <- table(df2[[v]], df2$blood_glucose)
  suppressWarnings(chisq.test(tab)$p.value)
})
p_cat

#generating numerical p values 
num_vars <- c("duration","n_diagnoses","n_medications","n_procedures","n_previous_visits")
p_num <- sapply(num_vars, function(v) {
  suppressWarnings(t.test(df2[[v]] ~ df2$blood_glucose)$p.value)
})
p_num

###TASK 3: 

#creating ps model
ps_model <- glm(
  blood_glucose ~ age + sex + race + admission_source + insurer +
    duration + n_medications + n_procedures + n_diagnoses,
  data = df,
  family = binomial
)
summary(ps_model)

#extracting ps 
df_ps <- df %>%
  mutate(ps = predict(ps_model, newdata = df_ps, type = "response"))

ps_summary <- df_ps %>%
  group_by(blood_glucose) %>%
  summarise(
    n = n(),
    mean = mean(ps),
    sd = sd(ps),
    min = min(ps),
    p25 = quantile(ps, 0.25),
    median = median(ps),
    p75 = quantile(ps, 0.75),
    max = max(ps)
  )
ps_summary

#creating density plot 
density_plot <- ggplot(df_ps, aes(x = ps, fill = blood_glucose)) +
  geom_density(alpha = 0.4, colour="black") +
  labs(
    x = "Propensity score (P[High glucose])",
    y = "Density",
    fill = "Blood glucose"
  ) +
  theme_minimal(base_size = 14)
density_plot
ggsave("ps_density_plot.png", plot = density_plot, width = 6, height = 4, dpi = 300)


###TASK 4: 

#calculating IPTW weights
df_ps <- df_ps %>%
  mutate(
    w_iptw = ifelse(blood_glucose == "High", 1 / ps, 1 / (1 - ps))
  )
summary(df_ps$ps)
summary(df_ps$w_iptw)

#truncating extreme weights
w99 <- quantile(df_ps$w_iptw, 0.99, na.rm = TRUE)
df_ps <- df_ps %>%
  mutate(
    w_iptw_trunc = pmin(w_iptw, w99)
  )
summary(df_ps$w_iptw_trunc)

#fitting logistic regresssion
iptw_model <- glm(
  readmitted ~ blood_glucose,
  data = df_ps,
  family = quasibinomial,
  weights = w_iptw_trunc
)
summary(iptw_model)

#OR and CIs
iptw_or <- exp(cbind(OR = coef(iptw_model), confint(iptw_model)))
iptw_or

#creating multivariate model 
model_adj <- glm(readmitted ~ blood_glucose + age + sex + race + admission_source + insurer +
                   duration + n_medications + n_procedures + n_diagnoses,
                 data = df,
                 family = binomial ) 
summary(model_adj) 

#OR and CIs
adj_or <- exp(cbind(OR = coef(model_adj), confint(model_adj)))
adj_or