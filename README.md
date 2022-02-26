<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
# R_Tutorial

------

# **MARKDOWN 사용법**

[![마크다운사용법](http://img.youtube.com/vi/dUbp9wAy178/0.jpg)](https://youtu.be/dUbp9wAy178?t=0s) 



<iframe width="640" height="360" src="https://www.youtube.com/embed/dUbp9wAy178" frameborder="0" gesture="media" allowfullscreen=""></iframe>

[마크다운의 문법을 알아보자 (1편) (devorah.studio)](https://enoz.devorah.studio/65)

[Markdown 특수문자 사용](https://ascii.cl/htmlcodes.htm)

[수식블록](https://dev-lagom.tistory.com/35)

[수식블록상세](https://math.meta.stackexchange.com/questions/5020/mathjax-basic-tutorial-and-quick-reference)

------

## 통계분석방법

![Statistical_analysis_method](./Image/Statistical_analysis_method.png)

### 1. One Sample t-test
![One Sample t-test](./Image/One_Sample_t-test.png)

#### 가설

**귀무가설(*H*₀ ) : 파인트의 무게는 320g이다. ->** ***H*₀ : μ = 320**

**연구가설(*H*₁): 파인트의 무게는 320g이 아니다.  ->**  ***H*₁ : μ ≠ 320**



#### 통계치

$$
\begin{align} 
& 표본(n) : 100 \\
& 표본평균(\bar{x}) : 295.44 \\
& 표본표준편차 (s): 20.04,\ 표준오차(\frac {s} {\sqrt 𝑛}) : 2.004
\end{align}
$$

#### 임계치

$$
x_{critical}=μ_0 \pm 1.984 \frac{s}{\sqrt𝑛}= 320\pm1.984\frac{20.04}{\sqrt 100}=320\pm 3.97=[316.02,323.98]
$$

#### 검정통계량

$$
t_{cal} = \frac {\bar x - μ_0} {\frac{s}{\sqrt 𝑛}} = \frac { 295.4 - 320} {\frac{20.04}{\sqrt 100}} = \frac {-24.6}{2.004} = -12.25
$$

#### 유의확률(***p-value***) 계산

$$
\pmb p-\pmb value = 0.000
$$

------

![통계치](./Image/One_Sample_t-test_data.png)



------

## 분석결과

K대학 앞 점포에서 파는 아이스크림의 무게(295.44g)는 B아이스크 림회사에서 발표한 파인트의 무게(320g)보다 통계적으로 유의하게 적었다.(t(검정통계량)=-12.252, p(유의확률= 0.000).



|  구분  | 평균(M) | 표준편차(SD) | 검정량통계(t) | 유의확률(p) |    신뢰구간    |
| :----: | :-----: | :----------: | :-----------: | :---------: | :------------: |
| 무게() | 295.44  |    20.04     |    -12.526    |    0.000    | 316.02 ~323.98 |

![그래프(GRAPH)](./Image/One_Sample_t-test_graph.png)



### 교차분석(chi square) - 동질성 검정(사전실험연구)에 대해 설명



























### Correlation Test(상관분석)

![Correlation-test](./Image/Correlation_Sample-test.png)

#### 공분산(Covariance)  

두 변수간의 공통분산

공분산은 척도단위에 따라 민감하게 반응함  표준화 필요



#### 상관계수(Correlation Coefficient)

두 변수의 관계를 하나의 수치로 나타낸 척도



## 분석결과

몸무게과 키 사이에는 양의 상관관계가 있는 것으로 나타났다 (r＝ .86, p<.000).

|  변수  | 몸무게 |  키   |
| :----: | :----: | :---: |
| 몸무게 |   1    | ,86** |
|   키   | ,86**  |   1   |

|  변수  | 변수 | 상관계수(r) | 유의확률(p) | 상관계수선정방법 |
| :----: | :--: | :---------: | :---------: | :--------------: |
| 몸무게 |  키  |    0.86     |    0.000    |     Pearson      |

![Correlation-test_graph](./Image/Correlation_Sample-test_graph.png)