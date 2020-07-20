#libraries used
library(shiny)
library(stringr)
library(dplyr)
library(readr)
disc3 = 0.6
disc2 = 0.6
        onegram.df <- read_csv("onegram.csv")
        twogram.df <- read_csv("twogram.csv")
        tgram.df <- read_csv("tgram.csv")
        onegram.df<- onegram.df[,2:3]
        twogram.df <- twogram.df[,2:3]
       tgram.df <- tgram.df[,2:3]
        colnames(onegram.df)<- c("terms","X1")
        colnames(twogram.df)<- c("terms","X1")
        colnames(tgram.df)<- c("terms","X1")

        searchmatrix <- function(tgram.df,input){        
                searchpattern <- sprintf("%s%s","^",input)
                matchvalues <- grepl(searchpattern,tgram.df$terms)
                if(!(sum(matchvalues)==0)){
                        return(tgram.df[matchvalues, ])
                }
                else
                        return(data.frame(terms=NULL,X1=NULL))
        }
        #Creating probability using the Katz formula for 4-gram
        s.matrixProb <- function(ts.df,twogram.df,disc3,input){
                if(nrow(ts.df)<1) return(NULL)
                count <- filter(twogram.df, terms==input)$X1[1]
                s.matrixprob <- mutate(ts.df, X1=((X1 - disc3) / count))
                s.matrixprob <- data.frame(ngram=s.matrixprob$terms, prob=s.matrixprob$X1)
                s.matrixprob
        }
        #Getting all the words that we don't see in our trigram prediction
        Unusedtails <- function(ts.df, onegram.df) {
                tails <- str_split_fixed(as.matrix(ts.df), " ", 3)[, 3]
                unused_tails <- onegram.df[!(onegram.df$terms %in% tails), ]$terms
                return(unused_tails)
        }
        #Getting alpha twogram
        AlphaTwogram <- function(onegram.df, twogram.df, disc2) {
                # get all bigrams that start with unigram
                regex <- sprintf("%s%s", "^", onegram.df$terms)[1]
                bigsThatStartWithUnig <- twogram.df[grep(regex, twogram.df$terms),]
                if(nrow(bigsThatStartWithUnig) < 1) return(0)
                alphaBi <- 1 - (sum(bigsThatStartWithUnig$X1 - disc2) / onegram.df$X1)
                
                return(alphaBi)
        }
        #Creating Probability mass functions for discounted 
        #creating not found bigrams
         notfoundbigrams <- function(input,unusedtails){
                n.input <- str_split(input," ")[[1]][2]
                nftg<-paste(n.input ,unusedtails)
                return(nftg)
        } 
        #creating probabilities
        observenfbigrams <- function(twogram.df,input,unusedtails){
                nfbigrams <- notfoundbigrams(input,unusedtails)
                observenfbigrams <- twogram.df[(twogram.df$terms%in%nfbigrams), ]       
                return(observenfbigrams)
        }
        notobservednfbigrams <- function(twogram.df,input,unusedtails){
                nfbigrams <- notfoundbigrams(input,unusedtails)
                nt <- twogram.df[!(twogram.df$terms%in%nfbigrams), ]       
                nt
        }
        #Observed bigram's backed off probabilities
        ObsBigramProbs <- function(obs.nfbi, onegram.df, disc2) {
                first_words <- str_split_fixed(as.matrix(obs.nfbi), " ", 2)[, 1]
                first_word_freqs <- onegram.df[onegram.df$terms %in% first_words, ]
                obsBigProbs <- (obs.nfbi$X1 - disc2) / first_word_freqs$X1
                obsBigProbs <- data.frame(ngram=obs.nfbi$terms, prob=obsBigProbs)
                return(obsBigProbs)
        } 
        #unobserved bigram's probability
        getQboUnobsBigrams <- function(nobs.nfbi, onegram.df, alphatwo) {
                # get the unobserved bigram tails
                qboUnobsBigs <- str_split_fixed(as.matrix(nobs.nfbi), " ", 2)[, 2]
                w_in_Aw_iminus1 <- onegram.df[!(onegram.df$terms %in% qboUnobsBigs), ]
                # convert to data.frame with counts
                qboUnobsBigs <- onegram.df[onegram.df$terms %in% qboUnobsBigs, ]
                denom <- sum(qboUnobsBigs$X1)
                # converts counts to probabilities
                qboUnobsBigs <- data.frame(ngram=qboUnobsBigs$terms,
                                           prob=(alphatwo * qboUnobsBigs$X1 / denom))
                
                return(qboUnobsBigs)
        }
        # Getting alpha trigram
        AlphaTrigram <- function(ts.df, twogram.df, disc3,input) {
                bigram <- twogram.df[(twogram.df$terms==input),]
                if(nrow(ts.df) < 1) return(1)
                alphaTri <- 1 - sum((ts.df$X1 - disc3) / bigram$X1[1])
                return(alphaTri)
        }
        #Unobserved Trogram Probability
        getUnobsTriProbs <- function(input, obs.b.prob,nobs.b.prob, alphaTrig) {
                
                qboBigrams <- rbind(obs.b.prob, nobs.b.prob)
                qboBigrams <- qboBigrams[order(-qboBigrams$prob), ]
                sumQboBigs <- sum(qboBigrams$prob)
                first_bigPre_word <- str_split(input, " ")[[1]][2]
                unobsTrigNgrams <- paste(first_bigPre_word, qboBigrams$ngram, sep=" ")
                unobsTrigProbs <- alphaTrig * qboBigrams$prob / sumQboBigs
                unobsTrigDf <- data.frame(ngram=unobsTrigNgrams, prob=unobsTrigProbs)
                
                return(unobsTrigDf)
        }
        shinyServer(
                function(input, output) {
                       v1 <- reactiveValues(data=NULL)
                       v2 <- reactiveValues(data=NULL)
                       v3 <- reactiveValues(data=NULL)
                        observeEvent(input$go , {
                                search <- str_split(input$sentence," ")
                                words <- length(search[[1]])
                                input <- paste(search[[1]][(words-1)],search[[1]][words])
                               ts.df <- searchmatrix(tgram.df,input)
                               trig.obs.prob <- s.matrixProb(ts.df,twogram.df,disc3,input)
                               unusedtails <- Unusedtails(ts.df,onegram.df)
                               modinp <-str_split(input, " ")[[1]][2]
                               unigs <- onegram.df[onegram.df$terms==modinp,]
                               alphatwo <- AlphaTwogram(unigs,twogram.df,disc2)
                               obs.nfbi <- observenfbigrams(twogram.df,input,unusedtails)
                               nobs.nfbi <- notobservednfbigrams(twogram.df,input,unusedtails)
                               obs.b.prob <-ObsBigramProbs(obs.nfbi,onegram.df,disc2)
                               nobs.b.prob <- getQboUnobsBigrams(nobs.nfbi,onegram.df,alphatwo)
                               alpha_trig <- AlphaTrigram(ts.df, twogram.df, disc3,input)
                               trig.nobs.prob <- getUnobsTriProbs(input, obs.b.prob,nobs.b.prob, alpha_trig)
                               trigsprobs <- rbind(trig.obs.prob,trig.nobs.prob)
                               trigsprobs <- trigsprobs[order(-trigsprobs$prob), ]
                               out1<- str_split(trigsprobs$ngram[1]," ")[[1]][3]
                               out2<- str_split(trigsprobs$ngram[2]," ")[[1]][3]
                               out3<- str_split(trigsprobs$ngram[3]," ")[[1]][3]
                               v1$data <- out1
                               v2$data <- out2
                                v3$data <- out3
                               })
                        
                 output$pred1 = renderPrint({v1$data})
                 output$pred2 = renderPrint({v2$data})
                 output$pred3 = renderPrint({v3$data})
                }
        )


        
        

        
        
        
        
        