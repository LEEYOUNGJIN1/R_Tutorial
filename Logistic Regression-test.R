# 로지스틱 회귀분석(Logistic Regression)

# 문제
# K기업의 인사담당인 이부장은 신체적 건강과 심리적건강, 조직몰입,
# 이직경험이 이직의도에 영향을 준다고 보고, 이들간의 인과관계를 연구하고자 한다

# 1.기본 package 설정, library 로드
library(tidyverse)
library(tidymodels)
library(rstatix)
library(skimr)
library(lm.beta)


# 2.데이터 불러오기 
lr_tb <- read_csv('data/LR.csv', 
                  col_names = TRUE,
                  locale=locale('ko', encoding='euc-kr'), # 한글
                  na=".") %>%
  mutate_if(is.character, as.factor) %>%
  mutate(exp = factor(exp,
                      levels=c(0,1),
                      labels=c("No","Yes"))) %>%
  mutate(chun = factor(chun,
                       levels=c(0:1),
                       labels=c("No","Yes")))

str(lr_tb)
lr_tb

# 3.기본통계치 확인
skim(lr_tb)

lr_tb %>%
  get_summary_stats()

# 4.그래프 그리기
pairs( ~ phy+psy+cmmt, data=lr_tb)

# 5.로지스틱 회귀분석
lr_fit <- glm(chun ~ phy+psy+cmmt+exp, 
              family = binomial, 
              data=lr_tb) 

# ANOVA 분석
summary(lr_fit)

# 회귀계수
tidy(lr_fit, conf.int = TRUE)

# 설명력R2
glance(lr_fit)

# Odds 계산
tidy(lr_fit, conf.int = TRUE) %>%
  mutate(odds = exp(coef(lr_fit))) %>%
  write_csv("table/lr_tb.csv") 

