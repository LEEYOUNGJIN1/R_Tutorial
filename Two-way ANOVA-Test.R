# 이원 분산분석(Two-way ANOVA)

# 문제
# 치킨의 맛을 결정하는 두 가지 요인은 튀길 때의 기름 온도와 튀기는 방법이다.
# 튀길 때의 온도를 200도와 300도로 하고, 튀기는 방법을 오븐과 기름으로 하여
# 치킨을 튀긴 후에 사람들에게 맛을 평가하도록 하였다. 
# 과연 온도와 시간이 맛을 결정하는데 중요한 요인인가? 이 두 가지 요인들간의
# 상호작용효과는 없었는가?

# 1.기본 package 설정, library 로드
library(tidyverse)
library(tidymodels)
library(rstatix)
library(skimr)

# 2.데이터 불러오기 
twa_tb <- read_csv('data\\TWA.csv', 
                   col_names = TRUE,
                   locale=locale('ko', encoding='euc-kr'), # 한글
                   na=".") %>%
  round(2) %>%                 # 소수점 2자리로 반올림
  mutate_if(is.character, as.factor) %>%
  mutate(방법 = factor(방법,
                       levels=c(1:2),
                       labels=c("오븐","기름"))) %>%
  mutate(온도 = factor(온도,
                       levels=c(1:2),
                       labels=c("200도","300도")))

str(twa_tb)
twa_tb




# 3.기술통계분석
# 상호작용호과에 관심있는 변수를 2번째 표시 (온도)
skim(twa_tb)

twa_tb %>% 
  group_by(방법, 온도) %>%
  get_summary_stats(맛점수)




# 4.그래프 그리기(박스그래프,히스토그램)
twa_tb %>% 
  ggplot(mapping = aes(x = 방법,
                       y = 맛점수,
                       color = 방법)) +
  geom_boxplot() +
  facet_wrap(~ 온도)

twa_tb %>% 
  ggplot(mapping = aes(x = 맛점수)) +
  geom_histogram(bins = 10,               # binwidth=1,000: 값차이
                 color = "white", 
                 fill = "steelblue") +
  facet_wrap(~ 방법*온도)                   # 그룹별 분리

# 상화작용 검정
twa_tb %>% 
  group_by(온도, 방법) %>% 
  summarise(맛점수 = mean(맛점수)) %>% 
  ggplot(mapping = aes(x = 온도, 
             y = 맛점수, 
             color = 방법)) +
  geom_line(mapping = aes(group = 방법)) +
  geom_point()




# 5.이상치 제거
# 이상치 확인
twa_tb %>%
  group_by(방법, 온도) %>%
  identify_outliers(맛점수)




# 6.정규분포 검정
twa_tb %>%
  group_by(방법, 온도) %>%
  shapiro_test(맛점수)




# 7.등분산 검정
# 이분산일때는 하단의 Welch's ANOVA test 참조
twa_tb %>%
  levene_test(맛점수 ~ 방법*온도)




# 8.등분산 ANOVA
# 등분산일때 ANOVA분석
twa_result <- aov(맛점수 ~ 방법 + 온도 + 방법:온도, 
                     data=twa_tb)
tidy(twa_result)


# 상호작용이 없을 경우 : 마지막 부록 참조




# 9.사후검정(Multicamparison test )
# 상호작용이 있을 경우 : 그룹별로 나누어서 분석
# 상호작용이 없을 경우 : 각 변수별 주효과 분석(t-test, ANOVA분석)

# Fisher LSD
twa_tb %>%
  group_by(온도)%>%
  pairwise_t_test(맛점수 ~ 방법,
                  p.adj="bonferroni")




# 부록: 상호작용 없을 경우
# 상호작용이 없을 경우 : 상호작용효과(방법:온도) 제거하고 다시 분석
# 상호작용이 없을 경우 : 각 변수별 주효과 분석(t-test, ANOVA분석)

twa_result <- aov(맛점수 ~ 방법 + 온도, 
                     data=twa_tb)
tidy(twa_result)

twa_tb %>%
  pairwise_t_test(맛점수 ~ 방법, 
                     p.adj="bonferroni")
twa_tb %>%
  pairwise_t_test(맛점수 ~ 온도, 
                     p.adj="bonferroni")

