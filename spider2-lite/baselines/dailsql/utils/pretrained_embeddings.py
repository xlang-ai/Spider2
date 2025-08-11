import abc
import functools
import os
import time

import bpemb
import corenlp
import torch
import torchtext

from utils.linking_utils import corenlp
import spacy


class Embedder(metaclass=abc.ABCMeta):

    @abc.abstractmethod
    def tokenize(self, sentence):
        '''Given a string, return a list of tokens suitable for lookup.'''
        pass

    @abc.abstractmethod
    def untokenize(self, tokens):
        '''Undo tokenize.'''
        pass

    @abc.abstractmethod
    def lookup(self, token):
        '''Given a token, return a vector embedding if token is in vocabulary.
        If token is not in the vocabulary, then return None.'''
        pass

    @abc.abstractmethod
    def contains(self, token):
        pass

    @abc.abstractmethod
    def to(self, device):
        '''Transfer the pretrained embeddings to the given device.'''
        pass


class GloVe(Embedder):

    def __init__(self, kind, lemmatize=False):
        cache = os.path.join(os.environ.get('CACHE_DIR', os.getcwd()), 'vector_cache')
        self.glove = torchtext.vocab.GloVe(name=kind, cache=cache)
        self.dim = self.glove.dim
        self.vectors = self.glove.vectors
        self.lemmatize = lemmatize
        self.corenlp_annotators = ['tokenize', 'ssplit']
        if lemmatize:
            self.corenlp_annotators.append('lemma')

        self.nlp = spacy.load("en_core_web_sm")  

    @functools.lru_cache(maxsize=1024)
    def tokenize_by_coreNLP(self, text):
        ann = corenlp.annotate(text, self.corenlp_annotators)
        if self.lemmatize:
            return [tok.lemma.lower() for sent in ann.sentence for tok in sent.token]
        else:
            return [tok.word.lower() for sent in ann.sentence for tok in sent.token]

    @functools.lru_cache(maxsize=1024)
    def tokenize_for_copying_by_coreNLP(self, text):
        ann = corenlp.annotate(text, self.corenlp_annotators)
        text_for_copying = [tok.originalText.lower() for sent in ann.sentence for tok in sent.token]  
        if self.lemmatize:
            text = [tok.lemma.lower() for sent in ann.sentence for tok in sent.token]
        else:
            text = [tok.word.lower() for sent in ann.sentence for tok in sent.token]
        return text, text_for_copying

    @functools.lru_cache(maxsize=1024)
    def tokenize(self, text):
        doc = self.nlp(text)
        if self.lemmatize:
            return [token.lemma_.lower() for token in doc]
        else:
            return [token.text.lower() for token in doc]

    @functools.lru_cache(maxsize=1024)
    def tokenize_for_copying(self, text):
        doc = self.nlp(text)
        text_for_copying = [token.text.lower() for token in doc]
        if self.lemmatize:
            text = [token.lemma_.lower() for token in doc]
        else:
            text = [token.text.lower() for token in doc]
        return text, text_for_copying

    def untokenize(self, tokens):
        return ' '.join(tokens)

    def lookup(self, token):
        i = self.glove.stoi.get(token)
        if i is None:
            return None
        return self.vectors[i]

    def contains(self, token):
        return token in self.glove.stoi

    def to(self, device):
        self.vectors = self.vectors.to(device)