# 일원 분산분석(One-way ANOVA)

#통계분석
#차이검정 : 일원 분산분석(One-way ANOVA) ANOVA-test
#문제
#별다방을 프렌차이즈 운영하는 K회사는 강남, 강동, 강서, 강북에 위치한 매장의 서비스에 대한 고객조사를 실시하였다. 
#과연 4곳 매장의 고객만족도는 차이가 있는지? 있다면 어느 레스토랑의 서비스 만족도가 가장 안 좋은가 확인해보자


# 1.기본 package 설정

# 1.1 library 로드
library(tidyverse)
library(tidymodels)
library(rstatix)
library(skimr)

# 2.데이터 불러오기 
owa_tb <- read_csv('data\\owa.csv', 
                   col_names = TRUE,
                   locale=locale('ko', encoding='euc-kr'), # 한글
                   na=".") %>%
  round(2) %>%                 # 소수점 2자리로 반올림
  mutate_if(is.character, as.factor) %>%
  mutate(매장명 = factor(매장명,
                          levels=c(1:4),
                          labels=c("강남","강서","강동","강북")))

str(owa_tb)
owa_tb

# 3.기술통계분석
skim(owa_tb)

owa_tb %>% 
  group_by(매장명) %>%
  get_summary_stats(만족도)

# 4.그래프 그리기(박스그래프,히스토그램)
owa_tb %>% 
  ggplot(mapping = aes(x = 매장명,
                       y = 만족도)) +
  geom_boxplot() +
  labs(y = "매장별 만족도")

owa_tb %>% 
  ggplot(mapping = aes(x = 만족도)) +
  geom_histogram(bins = 10,               # binwidth=1,000: 값차이
                 color = "white", 
                 fill = "steelblue") +
  facet_wrap(~ 매장명)                   # 그룹별 분리

# 5.이상치 제거, 이상치 확인
owa_tb %>%
  group_by(매장명) %>%
  identify_outliers(만족도)

# 6.정규분포 검정
owa_tb %>%
  group_by(매장명) %>%
  shapiro_test(만족도)

# 7.등분산 검정
# 이분산일때는 하단의 Welch's ANOVA test 참조
owa_tb %>%
  levene_test(만족도 ~ 매장명)

# 8.등분산 ANOVA
# 등분산일때 ANOVA분석
owa_result <- aov(만족도 ~ 매장명, 
                  data=owa_tb)
tidy(owa_result) 


owa_tb %>%
  anova_test(만족도 ~ 매장명)

# Cohen’s d(effect size)
# 0.2 (small effect), 0.5 (moderate effect) and 0.8 (large effect)
owa_tb %>% 
  cohens_d(formula = 만족도 ~ 매장명, 
           var.equal = TRUE)


# 9.사후검정(Multicamparison test )
# Fisher LSD
owa_tb %>% 
  pairwise_t_test(만족도 ~ 매장명, 
                  p.adj="non") %>%
  mutate_if(is.numeric, round, 5)

# Bonferroni
owa_tb %>% 
  pairwise_t_test(만족도 ~ 매장명, 
                  p.adj="bonferroni") %>%
  mutate_if(is.numeric, round, 5)

# Tukey HSD
owa_result %>% 
  TukeyHSD() %>% 
  tidy() 

# 매장명으로 표현
# install.packages("agricolae")
library(agricolae)

# console=TRUE: 결과를 화면에 표시
# 매장명=TRUE: 그룹으로 묶어서 표시, FALSE: 1:1로 비교
# LSD.test, duncan.test, scheffe.test
owa_result %>%
  LSD.test("매장명",
           group=TRUE, 
           console = TRUE)

owa_result %>%
  duncan.test("매장명",
              group=TRUE, 
              console = TRUE)

owa_result %>%
  scheffe.test("매장명",
               group=TRUE, 
               console = TRUE)


# 다중비교 그래프
owa_result %>% 
  TukeyHSD() %>% 
  plot() 


# 10.추론(infer)을 이용한 가설검정 및 그래프
# f_cal 계산
f_cal <- owa_tb %>%
  specify(formula = 만족도 ~ 매장명) %>% # hypothesize 없음
  calculate(stat = "F") %>%
  print()

# Bootstrapping을 이용한 귀무가설 분포 생성 
set.seed(123) 
null_dist_f <- owa_tb %>%
  specify(formula = 만족도 ~ 매장명) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "F") %>%
  print()

null_dist_f %>%
  visualize(method = "both") +           #method = "both": 이론분포+boot분포
  shade_p_value(obs_stat = f_cal,
                direction = "greater")

# p_value
null_dist_f %>%
  get_p_value(obs_stat = f_cal,           
              direction = "greater") %>%
  print()





# 부록: 이분산(levene_test < 0.05) 일때 Welch's ANOVA test
owa_tb %>% 
  welch_anova_test(만족도 ~ 매장명)

owa_tb %>% 
  pairwise_t_test(만족도 ~ 매장명, 
                  pool.sd = FALSE,      # 등분산 가정 안함
                  p.adj="bonferroni")


# 부록: 정규분포 가정 문제가 있으면 shapiro_test < 0.05
# 비모수통계분석 Kruskal Wallis H test 
owa_tb %>%
  kruskal_test(만족도 ~ 매장명)

# 비모수 다중비교 Dunn test 
owa_tb %>% 
  dunn_test(만족도 ~ 매장명)


