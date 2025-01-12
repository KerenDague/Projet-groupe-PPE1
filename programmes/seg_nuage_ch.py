import jieba
from wordcloud import WordCloud
import matplotlib.pyplot as plt
from PIL import Image
import numpy as np
from collections import Counter
from nltk.tokenize import RegexpTokenizer


with open(input_file, 'r', encoding='utf-8') as f_in:
    text = f_in.read()  
    seg_list = jieba.cut(text, cut_all=False, HMM=True)  
    with open(segmented_file, 'w', encoding='utf-8') as f_out:
        f_out.write(' '.join(seg_list))  

with open(segmented_file, 'r', encoding='utf-8') as f_seg:
    tokenizer = RegexpTokenizer("[\u4e00-\u9fa5]{2,}")  
    tokens = tokenizer.tokenize(f_seg.read())  

with open(stopword_file, 'r', encoding='utf-8') as f_sw:
    stopwords = set(line.strip() for line in f_sw)  

filtered_tokens = [word for word in tokens if word not in stopwords]  
word_count = Counter(filtered_tokens)  
top_words = word_count.most_common(100)  
word_freq = dict(word_count)


mask = np.array(Image.open(mask_image_path))  
wordcloud = WordCloud(
    background_color='white',
    font_path='/System/Library/Fonts/Supplemental/Songti.ttc',  
    scale=4,
    mask=mask,  
    contour_width=2
).generate_from_frequencies(word_freq)  

wordcloud.to_file(output_image_path)  

plt.imshow(wordcloud, interpolation='bilinear')
plt.axis('off')
plt.show()


input_file = './itrameur/dumps-text-chinois.txt'  
segmented_file = './itrameur/dumps-text-ch_seg.txt' 
stopword_file = './itrameur/stopwords_ch.txt'  
mask_image_path = './annexes/images/education.png'  
output_image_path = './annexes/images/nuageCH.png'  



