import connexion
import six

from swagger_server.models.book_success import BookSuccess  # noqa: E501
from swagger_server.models.error_model import ErrorModel  # noqa: E501
from swagger_server import util


def book_get():  # noqa: E501
    """book_get

    List the books. # noqa: E501


    :rtype: BookSuccess
    """
    return 'do some magic!'
