# MIT License
#
# Copyright (c) 2019 seq2struct contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import sys

import corenlp
import requests


class CoreNLP:
    def __init__(self):
        if not os.environ.get('CORENLP_HOME'):
            os.environ['CORENLP_HOME'] = os.path.abspath(
                os.path.join(
                    os.path.dirname(__file__),
                    '../../third_party/stanford-corenlp-full-2018-10-05'))
        if not os.path.exists(os.environ['CORENLP_HOME']):
            raise Exception(
                f'''Please install Stanford CoreNLP and put it at {os.environ['CORENLP_HOME']}.
                Direct URL: http://nlp.stanford.edu/software/stanford-corenlp-full-2018-10-05.zip
                Landing page: https://stanfordnlp.github.io/CoreNLP/''')
        self.client = corenlp.CoreNLPClient(endpoint="http://localhost:9001")  

    def __del__(self):
        self.client.stop()

    def annotate(self, text, annotators=None, output_format=None, properties=None):
        try:
            result = self.client.annotate(text, annotators, output_format, properties)
        except (corenlp.client.PermanentlyFailedException,
                requests.exceptions.ConnectionError) as e:
            print('\nWARNING: CoreNLP connection timeout. Recreating the server...', file=sys.stderr)
            self.client.stop()
            self.client.start()
            result = self.client.annotate(text, annotators, output_format, properties)

        return result


_singleton = None


def annotate(text, annotators=None, output_format=None, properties=None):
    global _singleton
    if not _singleton:
        _singleton = CoreNLP()
    return _singleton.annotate(text, annotators, output_format, properties)
