---
title: Computer Vision
description: Intro to Convolutional Neural Nets
marp: true
theme: uncover
_class: lead
paginate: true
backgroundColor: white
backgroundImage: url('https://source.unsplash.com/_JpQfgcCa2o')

---
<!-- paginate: false -->
<!-- _color: white-->

![bg](https://source.unsplash.com/OI1ToozsKBw)


# M3: Computer Vision <!-- fit -->
### Intro to Convolutional Neural Nets
###### Roman Jurowetzki

---

Let's start by unpacking what visual data actually is: Images are matrices!

![](https://cdn-images-1.medium.com/max/1600/1*Lxwa60XPX4H2X67aM4hvtg.png)

![bg right](https://media.giphy.com/media/smzfl3E7a4iHK/giphy.gif)




---



- That means that actually we have all the information about what is on the image right there in numbers describing each and every pixel, right? Wrong!

- The problem with images that the morst important information is not the what we can learn from each pixel but from the spatial interaction between them.

---


- Thus, the (relevant) information contained in an image is not the sum of all pixel values.


- The currently most widely used and extremely well performing approach to computer vision is convolution and more specifically deep convolutional neural networks. 

---
### A full CNN architecture

![w:1200](https://cdn-images-1.medium.com/max/2000/1*w5peCK-AeSI9D0PRT8oiZw.png)

---

To understand what the relevant features are hidden in the image we need to understand how individual pixels interact – We need to identify patterns. 

![bg left](https://images.unsplash.com/photo-1521846562476-9c2446539e47?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=cc956433f2bc33db1424a895f18d1463&auto=format&fit=crop&w=1651&q=80)


---
![bg right:25% w:80%](https://cdn-images-1.medium.com/max/1600/1*4h_J0Zpx93_sFHKxWUoHAw.gif)

- For this we use convolutions. This explanation will be rather simplistic but good enough for our purposes.

- Now, imagine you make a large banner with a rectangular hole in it and start sliding it over that brick wall - left to right, up to down. Obviously, you will see some very different patterns at different times. Every time you see something interesting, you note it down. That's convolution in a nutshell:

---

![alt text](https://cdn-images-1.medium.com/max/1600/1*ZCjPUFrB6eHPRi4eyP6aaA.gif)

A really [great post](https://medium.com/impactai/cnns-from-different-viewpoints-fab7f52d159c
) about CNN from different viewpoints: 

- Imagine now, instead of one window, you have many windows with different shapes to detect different features...

---

### Adding MaxPooling

![bg right](https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Geoffrey_Hinton_at_UBC.jpg/359px-Geoffrey_Hinton_at_UBC.jpg)
> The pooling operation used in convolutional neural networks is a big mistake and the fact that it works so well is a disaster. - Geoffrey Hinton

--- 

<!-- _color: white -->
<!-- backgroundImage: none -->
<!-- backgroundColor: black -->


- Convolution is great. But what if we want to capture information about the same objects but they are in different perspectives?

![bg left](https://s3files.core77.com/blog/images/635458_81_65314_WlVo6sJuI.jpg)

---

<!-- _color: white -->
<!-- backgroundImage: none -->


### Max pooling helps us


*   preserve features
*   achieve spacial invariance
*   reduce size and number of parameters (preventing overfitting)

![bg right:30%](https://cdn.fstoppers.com/styles/full/s3/media/2016/04/08/katja_jemec_-_i_looked_up_and_there_you_were_1.jpg)

---

![bg fit](https://developers.google.com/machine-learning/practica/image-classification/images/maxpool_animation.gif)

---
<!-- backgroundColor: white -->

- Now, let's check out [something fun:](http://scs.ryerson.ca/~aharley/vis/conv/)

- The final layer is creating the input we need for a neural net - it's a simple flattening operation


---


![bg](https://missinglink.ai/wp-content/uploads/2019/04/Group-5.png)

---

- From here we using an ANN for classification or regression...or whatever you are able to put together...

- The end.

