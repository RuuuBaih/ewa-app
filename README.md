# Ewa

Don't know what to eat? Ewa help you decide your breakfast, lunch and dinner!

## Overview

Ewa combines Pixnet poi API, Google Custom Search API and Google Map API, recommending you delicious restaurants with restaurants information, related food blog articles, and Google map rating and reviews. We hope to solve the "Don't know what to eat for ...?" issues and make our life simpler by choosing the food based on the restaurants recommended by Ewa!

## Status
[![Ruby v2.7.1](https://img.shields.io/badge/Ruby-2.7.1-green)](https://www.ruby-lang.org/en/news/2020/03/31/ruby-2-7-1-released/)

## Short-term usability goals

- Pull data from Pixnet API, Google Custom Search API and Google Map API.
- Randomize recommending the restaurants based on certain conditions.
- Combine restaurants information, related blog articles, Google map rating, reviews, and beautiful photos.

## Long-term goals

- Recommand restaurants based on users' preferences.


## [Website usage](http://soa2020-ewa.herokuapp.com)
### Home page
1. On the home page, you can see top 9 clicked restaurants' pictures on the page. They order from left to right, up to down.
2. You can click on the restaurant picture, and it will show you the related restaurant infos about that restaurant. I will introduce deeper in the restaurant detail page.
3. On the right up corner, you can use it to search part of restaurant name. It will show you the restaurant you are interested in. For example, search "阿默" will show you info about a restaurant which name is "阿默蛋糕". **To remind you, the searching is capital sensitive.**
4. On the left up corner, you can see a history combobox. It will record the restaurant that you had clicked before. If the green notice flash bar shows on the top of the page, it means that the restaurant hasn't been clicked before. It is loading data, and you should wait for a couple seconds and click the restaurant later.

### Recommend page
1. On the home page, you can use the search bar in the middle to filter the town and money range of the restaurant.
2. In the next page, you will see 9 recommended restaurants from Ewa and choose one to click. If you're not satisfied with the pictures, you can click try again.
3. As what 4. on the home page mentioned before, if you click on the restaurant that hasn't been clicked before, you will be redirected to home page. You can wait for a couple of seconds and click the restaurant that you clicked before by using the **History combobox** on the left up corner.

### Restaurant Details Page
1. On the restaurant details page, you can see some restaurant related basic infos. Such as: restaurant name (its name links to its related website), google rating, open hours, ewa tag. Also, you can see a google map section of this restaurant below the basic infos, and on the right side are the pictures of this restaurant.
2. You can scroll down, then you will see five reviews from google map about this restaurant, and one blog article about this restaurant. If you are not satisfied with the blog article, you can reload the page, we will re-random a blog article for you again.

**Ewa can't guarantee for the information quality, which is controlled by Google and Pixnet resources. However, we try to pick out those restaurants we think are the best for everyone. :)**

## License
2020, Rona Lu-Lai 呂賴臻柔
2020, Vivian Lu 盧宇涵
2020, Yan-Yu Fu 傅嬿羽
