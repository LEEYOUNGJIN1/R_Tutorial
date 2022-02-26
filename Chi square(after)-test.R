# 독립성 검정: 사후사례대조




# 1.기본 package 설정

# 1.1 library 로드
library(tidyverse)
library(tidymodels)
library(rstatix)
library(skimr)




# 2.데이터 불러오기 
postch_tb <- read_csv('17.PostCH.csv', 
                     col_names = TRUE,
                     locale=locale('ko', encoding='euc-kr'), # 한글
                     na=".") %>%
  round(2) %>%                 # 소수점 2자리로 반올림
  mutate_if(is.character, as.factor) %>%
  mutate(cancer = factor(cancer,
                         levels=c(1,2),
                         labels=c("No","Yes"))) %>%
  mutate(smoking = factor(smoking,
                          levels=c(1:5),
                          labels=c("비흡연군",
                                   "장기금연군",
                                   "단기금연군",
                                   "재흡연군",
                                   "흡연군")))

str(postch_tb)
postch_tb

skim(postch_tb)

# 표로 정리되어 있는 2차 데이터로 처리
postch_table <- xtabs(count ~ cancer + smoking ,
                      data=postch_tb)




# 3.그래프 그리기(모자이크) 
mosaicplot(~ smoking + cancer, 
           data = postch_table, 
           color = TRUE, cex = 1,.2)




# 4.카이스케어 분석
# install.packages("gmodels")
library(gmodels)


postch_fit <- CrossTable(postch_table,
                         expected=TRUE,
                         chisq=TRUE,
                         asresid=F)


# 5.수정된 표준잔차
postch_fit$chisq$stdres




# 6.오즈비(odds ratio)
# 위험요인과 질병 발생간의 연관성을 1을 기준으로 나타낸 척도
# 흡연을 하면 폐암에 걸릴 확률이 몇 배나 높아질 것인지?
norm_odds <- postch_fit$t[2,1]/postch_fit$t[1,1]
smok_odds <- postch_fit$t[2,5]/postch_fit$t[1,5]

smok_odds/norm_odds



