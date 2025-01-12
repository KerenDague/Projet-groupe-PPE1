import jieba
from collections import Counter
from nltk.tokenize import RegexpTokenizer


with open("../itrameur/contextes-chinois.txt", 'r', encoding='utf-8') as f_in:
    with open("../itrameur/contextes-chinois_seg.txt", 'w', encoding='utf-8') as f_out:
        text = f_in.read()
        seg_list = jieba.cut(text, cut_all=False, HMM=True) 
        f_out.write(' '.join(seg_list))

stopword_file = '../itrameur/stopwords_ch.txt'  
filtered_tokens = []


with open(stopword_file, 'r', encoding='utf-8') as f_sw:
    stopwords = set(line.strip() for line in f_sw)  

with open("../itrameur/contextes-chinois_seg.txt", 'r', encoding='utf-8') as f_seg:
    tokenizer = RegexpTokenizer("[\u4e00-\u9fa5]{2,}")  
    tokens = tokenizer.tokenize(f_seg.read())  

    filtered_tokens = [word for word in tokens if word not in stopwords]  
    with open("../itrameur/contextes-chinois_tok.txt", 'w', encoding='utf-8') as f_filtered:
        f_filtered.write(' '.join(filtered_tokens)) 