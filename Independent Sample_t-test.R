# 독립표본(Independent Sample) t-test
#통계분석
#차이검정 : 독립표본(Independent Sample) t-test
#문제
#이교수는 이번에 자동차 타이어를 교체하려고 하는데 수명이 긴 타이어로 교체하려고 한다. 
#시중에는 A회사의 타이어와 B회사의 타이어가 있는데, 이 교수는 이 중에서 어느 타이어를 골라야 하는가 ?

# 1.기본 package 설정, library 로드
library(tidyverse)
library(tidymodels)
library(rstatix)
library(skimr)

# 2.데이터 불러오기 
ist_tb <- read_csv('data\\IST.csv', 
                   col_names = TRUE,
                   locale=locale('ko', encoding='euc-kr'), # 한글
                   na=".") %>%
  round(2) %>%                 # 소수점 2자리로 반올림
  mutate_if(is.character, as.factor) %>%
  mutate(자동차회사 = factor(자동차회사,
                          levels = c("1","2"),
                          labels = c("A자동차",
                                     "B자동차")))
str(ist_tb)
ist_tb

# 3.기술통계분석
skim(ist_tb)

ist_tb %>% 
  group_by(자동차회사) %>%
  get_summary_stats(타이어수명)


# 4.그래프 그리기(박스그래프,히스토그램)
ist_tb %>% 
  ggplot(mapping = aes(x = 자동차회사,
                       y = 타이어수명)) +
  geom_boxplot() +
  labs(y = "타이어 수명")

ist_tb %>% 
  ggplot(mapping = aes(x = 타이어수명)) +
  geom_histogram(bins = 10,               # binwidth=1,000: 값차이
                 color = "white", 
                 fill = "steelblue") +
  facet_wrap(~ 자동차회사)                   # 그룹별 분리

# 5.이상치 제거(이상치 확인,이상치 제거) 
ist_tb %>%
  group_by(자동차회사) %>%
  identify_outliers(타이어수명)

ist_tb <- ist_tb %>%
  filter(!(자동차회사 == "A자동차" & 타이어수명 <= 38214 )) %>%
  filter(!(자동차회사 == "B자동차" & 타이어수명 <= 41852 )) 

ist_tb %>% 
  ggplot(mapping = aes(x = 자동차회사,
                       y = 타이어수명)) +
  geom_boxplot() +
  labs(y = "타이어 수명")

# 6.정규분포 검정
ist_tb %>%
  group_by(자동차회사) %>%
  shapiro_test(타이어수명)

# 7.등분산 검정
ist_tb %>%
  levene_test(타이어수명 ~ 자동차회사)

# 8.등분산 t-검정
#################################################
# two-sided test: alternative = c("two.sided")  #
# right-sided test: alternative = c("greater")  #
# left-sided test: alternative = c("less")      #
#################################################

# 등분산이면 var.equal=TRUE, 이분산이면 var.equal=FALSE
ist_tb %>% 
  t_test(formula = 타이어수명 ~ 자동차회사,
         comparisons = c("A자동차", "B자동차"),
         paired = FALSE,
         var.equal = TRUE,
         alternative = "two.sided",
         detailed = TRUE)

# Cohen’s d(effect size)
# 0.2 (small effect), 0.5 (moderate effect) and 0.8 (large effect)
ist_tb %>% 
  cohens_d(formula = 타이어수명 ~ 자동차회사, 
           var.equal = TRUE)

# 9.추론(infer)을 이용한 가설검정 및 그래프

# 9.1 표본평균(x)을 이용한 검정그래프 
# 표본평균(x) 계산 
x_bar <- ist_tb %>%
  specify(formula = 타이어수명 ~ 자동차회사) %>%   # hypothesize 없음
  calculate(stat = "diff in means",         # diff in means 변경
            order= c("A자동차", "B자동차")) %>%
  print()

# Bootstrapping을 이용한 귀무가설 분포 생성 
set.seed(123) 
null_dist_x <- ist_tb %>%
  specify(formula = 타이어수명 ~ 자동차회사) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "diff in means", 
            order= c("A자동차", "B자동차")) %>%
  print()

# 신뢰구간 생성 
null_dist_ci <- null_dist_x %>%
  get_ci(level = 0.95, 
         type = "percentile") %>%
  print()

# 그래프 그리기 
null_dist_x %>%
  visualize() +                                       # method 없음
  shade_p_value(obs_stat = x_bar,
                direction = "two-sided") +            # x_bar
  shade_confidence_interval(endpoints = null_dist_ci) # CI

# p_value
null_dist_x %>%
  get_p_value(obs_stat = x_bar,           
              direction = "two-sided") %>%
  print()

# 9.2 t값을 이용한 검정그래프 
# t_cal 계산
t_cal <- ist_tb %>%
  specify(formula = 타이어수명 ~ 자동차회사) %>% # hypothesize 없음
  calculate(stat = "t", 
            order= c("A자동차", "B자동차")) %>%
  print()

# Bootstrapping을 이용한 귀무가설 분포 생성 
set.seed(123) 
null_dist_t <- ist_tb %>%
  specify(formula = 타이어수명 ~ 자동차회사) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "t", 
            order= c("A자동차", "B자동차")) %>%
  print()

# 신뢰구간 생성 
null_dist_ci <- null_dist_t %>%
  get_ci(level = 0.95, 
         type = "percentile") %>%
  print()

null_dist_t %>%
  visualize(method = "both") +           #method = "both": 이론분포+boot분포
  shade_p_value(obs_stat = t_cal,
                direction = "two-sided") +
  shade_confidence_interval(endpoints = null_dist_ci)


# 부록. 비모수통계분석
# 정규분포검정 p < 0.05일 때 비모수 wilcox.test로 분석
ist_tb %>% 
  wilcox_test(formula = 타이어수명 ~ 자동차회사,
              alternative = "two.sided")
