import abc


class AbstractPreproc(metaclass=abc.ABCMeta):
    '''Used for preprocessing data according to the model's liking.
    Some tasks normally performed here:
    - Constructing a vocabulary from the training data
    - Transforming the items in some way, such as
        - Parsing the AST
        -
    - Loading and providing the pre-processed data to the model
    TODO:
    - Allow transforming items in a streaming fashion without loading all of them into memory first
    '''

    @abc.abstractmethod
    def validate_item(self, item, section):
        '''Checks whether item can be successfully preprocessed.

        Returns a boolean and an arbitrary object.'''
        pass

    @abc.abstractmethod
    def add_item(self, item, section, validation_info):
        '''Add an item to be preprocessed.'''
        pass

    @abc.abstractmethod
    def clear_items(self):
        '''Clear the preprocessed items'''
        pass

    @abc.abstractmethod
    def save(self):
        '''Marks that all of the items have been preprocessed. Save state to disk.
        Used in preprocess.py, after reading all of the data.'''
        pass

    @abc.abstractmethod
    def load(self):
        '''Load state from disk.'''
        pass

    @abc.abstractmethod
    def dataset(self, section):
        '''Returns a torch.data.utils.Dataset instance.'''
        pass
