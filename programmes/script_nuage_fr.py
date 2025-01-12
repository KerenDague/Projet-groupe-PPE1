import re
import matplotlib.pyplot as plt
from wordcloud import WordCloud
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
import nltk
nltk.download('stopwords')
nltk.download('punkt')


with open("./itrameur/dumps-text-fr.txt", 'r', encoding='utf-8') as file:
    text = file.read()

def clean_text(text):
    text = text.lower()
    text = re.sub(r'[^a-zàâçéèêëîïôûùüÿñæœ ]', '', text)
    words = word_tokenize(text)
    stop_words = stopwords.words('french')
    stop_words.extend(['comme','cette', 'plus', 'fait' , 'tout', 'apres', 'toute', 'bien', 'cest', "j'ai", 'si', 'faire', 'après', 'jai', 'peu', 'deux', 'donc'])
    words = [word for word in words if word not in stop_words]
    return " ".join(words)


raw_text = read_file(file_path)
cleaned_text = clean_text(raw_text)


wordcloud = WordCloud(
    width=800,
    height=400,
    background_color='white',
    colormap='viridis',
    max_words=200
).generate(cleaned_text)

plt.figure(figsize=(10, 5))
plt.imshow(wordcloud, interpolation='bilinear')
plt.axis('off')  # Pas d'axes
plt.title("Nuage de mots", fontsize=16)
plt.show()

