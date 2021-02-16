import connexion
import six

from swagger_server.models.error_model import ErrorModel  # noqa: E501
from swagger_server.models.inline_response200 import InlineResponse200  # noqa: E501
from swagger_server import util


def book_get():  # noqa: E501
    """book_get

    List the books # noqa: E501


    :rtype: InlineResponse200
    """
    return 'do some magic!'
