# 상관분석

## 문제의 정의
## K의류에서는 새로운 옷을 디자인하려고 하는데, 키와 몸무게가 어떤 관계가
## 있는지를 보고자 한다.

# 1.기본 package 설정

# 1.1 library 로드
library(tidyverse)
library(tidymodels)
library(rstatix)
library(skimr)

# 2.데이터 불러오기 
corr_tb <- read_csv('data/CORR.csv', 
                   col_names = TRUE,
                   locale=locale('ko', encoding='euc-kr'), # 한글
                   na=".") %>%
  mutate_if(is.character, as.factor)

str(corr_tb)

# 3.기본통계치 확인
skim(corr_tb)

corr_tb %>% 
  get_summary_stats(몸무게, 키)


# 4.그래프 그리기(산점도)
corr_tb %>%
  ggplot(mapping = aes(x = 몸무게,
                       y = 키)) +
  geom_jitter() +
  geom_smooth(method = "lm", se = TRUE)

# 5.상관분석
corr_tb %>%
  cor_test(몸무게, 키, 
           method = "pearson")
