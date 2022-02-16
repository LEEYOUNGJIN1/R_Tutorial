
# 통계분석
# 차이검정 : 일표본(One Sample) t-test
# B아이스크림회사에서 판매하는 아이스크림 중 파인트의 무게는 320g이다. 
# 그러나 K대학 앞에 있는 점포에서 파는 아이스크림의 무게가 320g이 아니라는 소비자들의 불만이 있었다. 
# 이에 따라 소비자단체에서는 B아이스크림회사에서 만든 아이스크림이 320g인지를 검사하고자 한다.



# 일표본(One Sample) t-test 

# 1.기본 package 설정

# 1.1 library 로드
library(tidyverse)
library(tidymodels)
library(rstatix)
library(skimr)

# 2.데이터 불러오기 
ost_tb <- read_csv('data/OST.csv', 
                   col_names = TRUE,
                   locale=locale('ko', encoding='euc-kr'), # 한글
                   na=".") %>%
  round(2) %>%                  # 소수점 2자리로 반올림
  mutate_if(is.character, as.factor)

str(ost_tb)
glimpse(ost_tb)
ost_tb

# 3.기본통계치 확인
skim(ost_tb)

ost_tb %>%
  get_summary_stats(weight)

ost_tb %>% 
  summarize(sample_size = n(),
            mean = mean(weight),
            sd = sd(weight),
            minimum = min(weight),
            lower_quartile = quantile(weight, 0.25),
            median = median(weight),
            upper_quartile = quantile(weight, 0.75),
            max = max(weight))

# 4.그래프 그리기(박스그래프,히스토그램)
ost_tb %>% 
  ggplot(aes(y = weight)) +
  geom_boxplot() +
  labs(y = "몸무게")

ost_tb %>% 
  ggplot(mapping = aes(x = weight)) +
  geom_histogram(binwidth = 10) +
  coord_cartesian(xlim=c(200, 400),       # coord_cartesian:좌표계
                  ylim=c(0, 30))

# 5.이상치 제거
# 이상치 확인
ost_tb %>% 
  identify_outliers(weight)

# 이상치 제거
ost_tb <- ost_tb %>%
  filter(!(weight <= 242))

ost_tb %>% 
  ggplot(aes(y = weight)) +
  geom_boxplot() +
  labs(y = "몸무게")

# 6.정규분포 검정
ost_tb %>%
  shapiro_test(weight)

# 7.통계분석
#################################################
# two-sided test: alternative = c("two.sided")  #
# right-sided test: alternative = c("greater")  #
# left-sided test: alternative = c("less")      #
#################################################

ost_tb %>% 
  t_test(formula = weight ~ 1,
         alternative = "two.sided",
         mu = 320.0, 
         conf.level = 0.95,
         detailed = TRUE)

# Cohen’s d(effect size)
# 0.2 (small effect), 0.5 (moderate effect) and 0.8 (large effect)
ost_tb %>% 
  cohens_d(formula = weight ~ 1, 
           mu = 320.0)
           
# 8.추론(infer)을 이용한 가설검정 및 그래프
# p.21 설명

# 8.1 표본평균(x)을 이용한 검정그래프 
# 표본평균(x) 계산 
x_bar <- ost_tb %>%
  specify(response = weight) %>%    # hypothesize 없음
  calculate(stat = "mean") %>%      # stat = "mean"
  print()

# Bootstrapping을 이용한 귀무가설 분포 생성 
set.seed(123) 
null_dist_x <- ost_tb %>%
  specify(response = weight) %>%
  hypothesize(null = "point", 
              mu = 320) %>%
  generate(reps = 1000, 
           type = "bootstrap") %>%
  calculate(stat = "mean") %>%
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

# 8.2 t값을 이용한 검정그래프 
# t_cal 계산 
t_cal <- ost_tb %>%
  specify(response = weight) %>%
  hypothesize(null = "point",         # hypothesize 필요
              mu = 320) %>%  
  calculate(stat = "t") %>%           # stat = "t"              
  print()

# Bootstrapping을 이용한 귀무가설 분포 생성 
set.seed(123) 
null_dist_t <- ost_tb %>%
  specify(response = weight) %>%
  hypothesize(null = "point", 
              mu = 320) %>%
  generate(reps = 1000, 
           type = "bootstrap") %>%
  calculate(stat = "t") %>%
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

