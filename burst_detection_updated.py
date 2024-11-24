#burst detection
import pandas as pd
import numpy as np
import scipy.stats as stats
from collections import Counter
from itertools import dropwhile
import string
import re
import burst_detection as bd
import seaborn as sns
import matplotlib.pyplot as plt

#format plots
sns.set(style='white', context='notebook', font_scale=1.5, 
        rc={'font.sans-serif': 'DejaVu Sans', 'lines.linewidth': 2.5})

#create a custom color palette
palette21 = ['#21618C', '#3498DB', '#AED6F1', '#00838F', '#00BFA5',
             '#F1C40F', '#F9E79F', '#E67E22', '#922B21', '#C0392B', 
             '#E6B0AA', '#6A1B9A', '#8E44AD', '#D7BDE2', '#196F3D', 
             '#4CAF50', '#A9DFBF', '#4527A0', '#7986CB', '#555555', 
             '#CCCCCC']
sns.palplot(palette21)

#create a color map
blog_blue = '#64C0C0'
blue_cmap = sns.light_palette(blog_blue, as_cmap=True)
############################################################################################################

data = pd.read_csv('exported_dataframe.csv', index_col=False)

data.insert(3, "words", range(len(data)), True)
for i in range(len(data)):
        data["words"][i] = data["kw"][i].lower().split(" ; ")
        for x in range(len(data["words"][i])):           
            data["words"][i][x] = data["words"][i][x].strip(string.punctuation)

#count all words in the articles keywords
word_counts = Counter(data['words'].apply(pd.Series).stack())

#remove words that appear fewer than X times
count_threshold = 10

for key, count in dropwhile(lambda x: x[1] >= count_threshold, word_counts.most_common()):
    del word_counts[key]
print('Number of unique words with at least',count_threshold,'occurances: ',len(word_counts))

#create a list of unique words
unique_words = list(word_counts.keys())
unique_words[:10]

#count the number of articles published each year
d = data.groupby(['PY'])['words'].count().reset_index(drop=True)

#initialize a figure
#plt.figure(figsize=(10,5))

#plot bars
#axes = plt.bar(d.index, d, width=1, color=blue_cmap(d.index.values/d.index.max()))  

#format plot
#plt.grid(axis='y')
#plt.xlim(0,len(d))
#plt.tick_params(axis='x', length=5)
#plt.title('Number of articles published each year')
#sns.despine(left=True)

#plt.tight_layout()
#plt.savefig('articles_published_over_time.png', dpi=300)
############################################################################################################

#create a dataframe to contain all target word propotions
all_r = pd.DataFrame(columns=unique_words, index=d.index)

for i, word in enumerate(unique_words):
    all_r[word] = pd.concat([data.loc[:,['PY']], 
                             data['words'].apply(lambda x: word in x)], 
                            axis=1) \
                    .groupby(by=["PY"]) \
                    .sum() \
                    .reset_index(drop=True)
            
    
def plot_most_common_words(word_counts, n, title, gradient, label_type):
    word_counts = pd.DataFrame(word_counts.most_common()[:n], columns=['word','count'])
    #define colors for bars
    if gradient:
        bar_colors = blue_cmap((word_counts['count'])/(word_counts['count'].max()))
    else:
        bar_colors = blog_blue
    #create a horizontal bar plot
    plt.barh(range(n,0,-1), word_counts['count'], height=0.85, color=bar_colors, alpha=1)
    #format plot
    sns.despine(left=True,bottom=True)
    plt.ylim(0,n+1)
    plt.title(title)
    plt.grid(axis='x')
    #label bars
    if label_type == 'counts':
        plt.yticks(range(n,0,-1), word_counts['word']);
        for i, row in word_counts.iterrows():
            plt.text(row['count']-100,50-i-0.2, row['count'], horizontalalignment='right', 
                     fontsize='12', color='white')
    elif label_type == 'labeled_bars_left':
        plt.yticks(range(n,0,-1), []);
        for i, row in word_counts.iterrows():
            plt.text(50,n-i-0.2, row['word'], horizontalalignment='left', fontsize='14')
    elif label_type == 'labeled_bars_right':
        plt.yticks(range(n,0,-1), []);
        for i, row in word_counts.iterrows():
            plt.text(row['count'],n-i-0.2,row['word'], horizontalalignment='right', fontsize='14')
    else:
        plt.yticks(range(n,0,-1), word_counts['word'])


from collections import Counter
word_counts_ = pd.DataFrame.from_records(list(dict(word_counts).items()), columns=['words','count'])
word_counts_ = word_counts_.sort_values(by = ["count"], ascending = False)
word_counts_ = word_counts_.iloc[0:15,:]

# Create bars
#plt.barh(word_counts_["words"], word_counts_["count"])

#plt.xlabel("counts")
#plt.title("Horizontal bar graph")

# Show graphic
#plt.show()

############################################################################################################
n=20
start_year = 2011

#create subplots
fig, axes = plt.subplots(2,5, figsize=(20,20), sharex=True, sharey=True);

for i, ax in enumerate(axes.flatten()):
    
    plt.subplot(2,5,i+1)
    
    #count words for the year
    year_word_counts = Counter(data.loc[data['PY']==start_year+i,'words'].apply(pd.Series).stack())
    
    #plot n most common words
    plot_most_common_words(word_counts = year_word_counts, n=n, 
                           title=str(start_year+i), gradient=True, label_type='labeled_bars_left')

############################################################################################################
start_year = 1991  #time frame start
end_year = 2020    #time frame end

#count all word occurances in the given time frame
word_counts_in_range = Counter(data.loc[(data['PY']>=start_year)&(data['PY']<=end_year),'words'].apply(pd.Series).stack())

#number of words to plot
n = 12

#pull out the N most common words and add to a word count dataframe
most_common_word_counts = pd.DataFrame(columns = pd.DataFrame(word_counts_in_range.most_common()[:n])[0],
                                       index = range(start_year,end_year+1))

#pull out counts of most common words for each year in the time frame
for word in most_common_word_counts.columns:
    most_common_word_counts[word] = pd.concat([data['PY'], data['words'].apply(lambda x: word in x)], axis=1) \
                                      .groupby(by=['PY']) \
                                      .sum()

most_common_word_counts = most_common_word_counts.drop(columns=["humans", "language"])


#initialize plot
plt.figure(figsize=(10,10))

#loop through most common words
for i, word in enumerate(most_common_word_counts.columns):
    
    #plot line
    plt.plot(range(start_year,end_year+1), 
             most_common_word_counts[word], 
             lw=4, color=palette21[i])
    
    #define the position for the label
    y_pos = most_common_word_counts.loc[end_year,word]
    #some labels overlap and need to be defined manually
    if word=='natural language processing':
        y_pos = y_pos+10
    if word=='sentiment analysis':
        y_pos = y_pos+10
    if word=='social media':
        y_pos = y_pos+10
    if word=='machine learning':
        y_pos = y_pos+10
    if word=='emotions':
        y_pos = y_pos+10
    if word=='text mining':
        y_pos = y_pos+10
    if word=='text analysis':
        y_pos = y_pos+10
    if word=='algorithms':
        y_pos = y_pos+10
    if word=='artificial intelligence':
        y_pos = y_pos+10
    if word=='data mining':
        y_pos = y_pos+10
    if word=='semantics':
        y_pos = y_pos+10
    if word=='internet':
        y_pos = y_pos+10
    if word=='linguistics':
        y_pos = y_pos+10
    if word=='natural language':
        y_pos = y_pos+10
    if word=='expert systems':
        y_pos = y_pos+10     
        
    #plot time series label in the same color
    plt.text(end_year+0.2, y_pos-10, word, fontsize=14, color=palette21[i])
    
#format plot
sns.despine(left=True, bottom=True)
plt.title('Counts of the 10 most common words')
plt.grid(axis='y', color='lightgray')

plt.xticks(range(start_year,end_year+1), range(start_year,end_year+1), rotation='vertical');

plt.xlim(start_year,end_year)
#plt.xticks((0, 9, 19, 29), (1991, 2000, 2010, 2020), fontsize = 8)

plt.tight_layout(rect=[0,0,0.85,1])
plt.savefig('most_common_word_in_the_last_30_years.png',dpi=1000)


############################################################################################################

#find bursts
#create a dataframe to hold results
all_bursts = pd.DataFrame(columns=['begin','end','weight'])

#define variables
s = 1         #resolution of state jumps; higher s --> fewer but stronger bursts
gam = 0.5     #difficulty of moving up a state; larger gamma --> harder to move up states, less bursty
n = 30    #number of timepoints

#loop through unique words
for i, word in enumerate(unique_words):
    r = all_r.loc[:,word].astype(int)
    #find the optimal state sequence (using the Viterbi algorithm)
    [q,d,r,p] = bd.burst_detection(r,d,n,s,gam,smooth_win=5)
    #enumerate the bursts 
    bursts = bd.enumerate_bursts(q, word)
    #find weight of each burst 
    bursts = bd.burst_weights(bursts, r, d, p)
    #add the bursts to a list of all bursts
    all_bursts = all_bursts.append(bursts, ignore_index=True)
    
all_bursts.sort_values(by='weight', ascending=False)

#save bursts to an excel file
all_bursts.to_excel("allburst.xlsx")

#visualize the bursts
all_bursts = pd.read_excel('allburst.xlsx', index_col=False)
all_bursts = all_bursts.iloc[:,2:6]

#sort bursts by start date
sorted_bursts = all_bursts.sort_values(by = ['begin_adjust', 'end_adjust'] , ascending=True).reset_index(drop=True)

sorted_bursts["begin_adjust"] = sorted_bursts["begin_adjust"]  - 5
sorted_bursts["end_adjust"] = sorted_bursts["end_adjust"]  - 5
sorted_bursts["label"] = sorted_bursts["label"]  + "  "

#format bars
bar_width = 0.3                                 #width of bars
bar_pos = np.array(range(len(sorted_bursts)))   #positions of top edge of bars
ylabel_pos = bar_pos + (bar_width/2)            #y axis label positions

#initialize the matplotlib figure
f, ax = plt.subplots(figsize=(10, 40))

##plot current bursts in blue and old bursts in gray
sorted_bursts['color'] = '#CCCCCC' #gray
#sorted_bursts.loc[sorted_bursts['end']==last_timepoint,'color'] = blog_blue
 
#plot the end points
end_bars = ax.barh(bar_pos, sorted_bursts.loc[:,'end_adjust'], bar_width, align='edge', 
        color=sorted_bursts['color'], edgecolor='none')

#plot the start points (in white to blend in with the background)
start_bars = ax.barh(bar_pos, sorted_bursts.loc[:,'begin_adjust'], bar_width, align='edge', 
        color='w', edgecolor='none')

#cut off "natural language processing"
ax.barh(3, 28-5, bar_width, align='edge', 
        color='w', edgecolor='none')

ax.barh(3, 25-5, bar_width, align='edge', 
        color='#CCCCCC', edgecolor='none')

ax.barh(3, 13-5, bar_width, align='edge', 
        color='w', edgecolor='none')

#label each burst
plt.yticks(ylabel_pos, '') #remove default labels
for burst in range(len(sorted_bursts)):
    width = int(end_bars[burst].get_width())
    #place label on right side for early bursts
    if width <= (5):
        plt.text(width, ylabel_pos[burst], sorted_bursts.loc[burst,'label'],
                fontsize=20, va='center')
    #place label on left side for late bursts
    else:
        width = int(start_bars[burst].get_width())
        plt.text(width, ylabel_pos[burst], sorted_bursts.loc[burst,'label'],
                fontsize=20, va='center', ha='right')
        
#format plot
ax.set(xlim=(0, 35), ylim=(0, 28), ylabel='', xlabel='')
ax.spines["top"].set_visible(False)    
ax.spines["bottom"].set_visible(False) 
ax.spines["left"].set_color([0.999, 0.999, 0.999])    
ax.spines["right"].set_color([0.999, 0.999, 0.999])

plt.xticks((0, 4, 9, 14, 19, 24), ("", 2000, 2005, 2010, 2015, 2020), fontsize = 20)

plt.savefig("bursts_top_s2.png", dpi=500)