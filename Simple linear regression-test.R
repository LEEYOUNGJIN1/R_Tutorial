# 단순 선형회귀분석(Simple linear regression)

# 문제
# 일개 기업체에서 근무하고 있는 직원(100명)들의 정규적인 건강검진 결과의
# 일부 자료이다. 콜레스테롤이 높으면 중성지방도 높다고 말할 수 있는가?
# 그렇다면 콜레스테롤과 중성지방 사이의 관련성을 회귀식으로 추정하시오

# 1.기본 package 설정, library 로드
library(tidyverse)
library(tidymodels)
library(rstatix)
library(skimr)

# 2.데이터 불러오기 
slr_tb <- read_csv('data/SLR.csv', 
                    col_names = TRUE,
                    locale=locale('ko', encoding='euc-kr'), # 한글
                    na=".") %>%
  mutate_if(is.character, as.factor)

str(slr_tb)
skim(slr_tb)


# 3.기본통계치 확인
slr_tb %>%
  get_summary_stats(fat, col)


# 4.그래프 그리기(산점도)
slr_tb %>%
  ggplot(mapping = aes(x = col,
                       y = fat)) +
  geom_jitter() +
  geom_smooth(method = "lm", se = TRUE)


# 5.단순회귀분석
## 표준화 회귀계수
install.packages("lm.beta")

library(lm.beta)

## 모델 생성
slr_fit <- lm(fat ~ ., data = slr_tb) %>%
  
# 표준화 회귀계수
lm.beta::lm.beta(slr_fit)

## ANOVA 분석
anova(slr_fit)

## 회귀계수
tidy(slr_fit, conf.int = TRUE)

## 설명력R2
glance(slr_fit)

# 6. 회귀분석 가정 검정
## 등분산성: Scale-Location, ncvTest
## 정규성: Nomal Q-Q, shapiro.test
## 선형성: Residuals vs Fitted, 
## 독립성: durbinWatsonTest
## 이상치검정 : Residuals vs Leverage(cook's distance) 4/n-k-1
## 그림으로 가정 검정
opar <- par(no.readonly = TRUE)
  par(mfrow=c(2,2))
  plot(slr_fit)
par(opar)

## 잔차의 정규분포 검정 
shapiro_test(slr_fit$residuals)

## 수치로 가정 검정(잔차의 등분산성 검정) 
car::ncvTest(slr_fit)

## 이상치 검정, sd, hat, d 통합검정
car::influencePlot(slr_fit, id.method="identify")

## 이상치 제거
slr_tb <- slr_tb[-c(61:62),]

# 7.단순회귀분석(이상치 제거)

## 모델 생성
slr_fit <- lm(fat ~ ., data = slr_tb) %>%
  lm.beta() # 표준화 회귀계수

## ANOVA 분석
anova(slr_fit)

## 회귀계수
tidy(slr_fit, conf.int = TRUE)

## 설명력R2
glance(slr_fit)

## 그림으로 가정 검정
opar <- par(no.readonly = TRUE)
par(mfrow=c(2,2))
plot(slr_fit)
par(opar)

## 잔차의 정규분포 검정 
shapiro_test(slr_fit$residuals)

## 수치로 가정 검정
library(car)

## 잔차의 등분산성 검정 
car::ncvTest(slr_fit)

## 이상치 검정, sd, hat, d 통합검정
car::influencePlot(slr_fit, id.method="identify")

# 8.모델을 이용한 예측
## 콜레스테롤이 130, 150일 경우 예측값
slr_tb_new <- data.frame(col=c(130,150))
predict(slr_fit, newdata = slr_tb_new)

      
