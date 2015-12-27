module C
  # This is a constants file that doesn't require a server restart and you can use these constants like GlobalConstants::STORAGE
  # C::Users::ROLES[:dioce] without adding anything
  class Answers
    DEFAULT_STATUS = 0
    STATUSES = [["N/A", 0], ["Correct", 1], ["Worng", 2]]
  end

  class Users
    ROLES = {client: "client", admin: "admin", dioce: "dioce"}
    STATUSES = [["N/A", 0], ["Correct", 1], ["Worng", 2]]
  end

  USER_INFO_FOUND = "USER_INFO_FOUND";
  NO_USER_INFO = "NO_USER_INFO";
  # //2xx Success
  # /**
  #  * Standard response for successful HTTP requests. The actual response will depend on the request method used. In a GET request, the response will contain an entity corresponding to the requested resource. In a POST request, the response will contain an entity describing or containing the result of the action
  #  */
  OK_STATUS_CODE = "200";
  SUCCESS_STATUS_MSG = "SUCCESS";
  FAILURE_STATUS_MSG = "FAILURE";
  AUTHORIZE_KEY = "AIzaSyBMZ11Ecc6BupqlVE7Cpxxw7XAgJUs7Q24";
  # /**
  #  * The request has been fulfilled and resulted in a new resource being created
  #  */
  CREATED_STATUS_CODE = "201";
  # /**
  #  * The request has been accepted for processing, but the processing has not been completed. The request might or might not eventually be acted upon, as it might be disallowed when processing actually takes place
  #  */
  ACCEPTED_STATUS_CODE = "202";
  # /**
  #  * The server successfully processed the request, but is returning information that may be from another source.
  #  */
  NON_AUTHORITATIVE_INFORMATION_STATUS_CODE = "203";
  # /**
  #  * The server successfully processed the request, but is not returning any content
  #  */
  NO_CONTENT_STATUS_CODE = "204";
  # /**
  #  * The server successfully processed the request, but is not returning any content. Unlike a 204 response, this response requires that the requester reset the document view
  #  */
  RESET_CONTENT_STATUS_CODE = "205";
  # /**
  #  * The server is delivering only part of the resource (byte serving) due to a range header sent by the client. The range header is used by HTTP clients to enable resuming of interrupted downloads, or split a download into multiple simultaneous streams
  #  */
  PARTIAL_CONTENT_STATUS_CODE = "206";
  # /**
  #  * The server has fulfilled a request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance
  #  */
  IM_USED_STATUS_CODE = "226";

  # //4xx Client Error
  # /**
  #  * "The server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing)."
  #  */
  BAD_REQUEST_STATUS_CODE = "400";
  # /**
  #  * Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not yet been provided. The response must include a WWW-Authenticate header field containing a challenge applicable to the requested resource. See Basic access authentication and Digest access authentication.[37] 401 semantically means "unauthenticated", i.e. "you don't have necessary credentials".
  #  */
  UNAUTHORIZED_STATUS_CODE = "401";
  # /**
  #  * The request was a valid request, but the server is refusing to respond to it. Unlike a 401 Unauthorized response, authenticating will make no difference.[39] 403 error semantically means "unauthorized", i.e. "you don't have necessary permissions for the resource".
  #  */
  FORBIDDEN_STATUS_CODE = "403";
  # /**
  #  * The requested resource could not be found but may be available again in the future. Subsequent requests by the client are permissible.
  #  */
  NOT_FOUND_STATUS_CODE = "404";
  # /**
  #  * A request was made of a resource using a request method not supported by that resource; for example, using GET on a form which requires data to be presented via POST, or using PUT on a read-only resource.
  #  */
  METHOD_NOT_ALLOWED_STATUS_CODE = "405";
  # /**
  #  * The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request
  #  */
  NOT_ACCEPTABLE_STATUS_CODE = "406";
  # /**
  #  * The server timed out waiting for the request. According to HTTP specifications: "The client did not produce a request within the time that the server was prepared to wait. The client MAY repeat the request without modifications at any later time."
  #  */
  REQUEST_TIMEOUT_STATUS_CODE = "408";
  # /**
  #  * Indicates that the request could not be processed because of conflict in the request, such as an edit conflict in the case of multiple updates.
  #  */
  CONFLICT_STATUS_CODE = "409";
  # /**
  #  * The server does not meet one of the preconditions that the requester put on the request
  #  */
  PRECONDITION_FAILED_STATUS_CODE = "412";
  # /**
  #  * The request entity has a media type which the server or resource does not support. For example, the client uploads an image as image/svg+xml, but the server requires that images use a different format.
  # */
  UNSUPPORTED_MEDIA_TYPE_STATUS_CODE = "415";
  # /**
  #  * Not a part of the HTTP standard, 419 Authentication Timeout denotes that previously valid authentication has expired. It is used as an alternative to 401 Unauthorized in order to differentiate from otherwise authenticated clients being denied access to specific server resources.
  #  */
  AUTHENTICATION_TIMEOUT_STATUS_CODE = "419";
  # /**
  #  * The request was well-formed but was unable to be followed due to semantic errors
  #  */
  UNPROCESSABLE_ENTITY_STATUS_CODE = "422";
  # /**
  #  * The user has sent too many requests in a given amount of time. Intended for use with rate limiting schemes
  #  */
  TOO_MANY_REQUESTS_STATUS_CODE = "429";
  # /**
  #  * A Microsoft extension. Indicates that your session has expired
  #  */
  LOGIN_TIMEOUT_STATUS_CODE = "440";
  # /**
  #  * Returned by ArcGIS for Server. A code of 498 indicates an expired or otherwise invalid token
  #  */
  TOKEN_EXPIRED_OR_INVALID_STATUS_CODE = "498";
  # /**
  #  * Returned by ArcGIS for Server. A code of 499 indicates that a token is required (if no token was submitted)
  #  */
  TOKEN_REQUIRED_STATUS_CODE = "499";

  # // 5 xx Server Error
  # /**
  #  * A generic error message, given when an unexpected condition was encountered and no more specific message is suitable
  #  */
  INTERNAL_SERVER_ERROR_STATUS_CODE = "500";
  # /**
  #  * The server either does not recognize the request method, or it lacks the ability to fulfill the request. Usually this implies future availability (e.g., a new feature of a web-service API)
  #  */
  NOT_IMPLEMENTED_STATUS_CODE = "501";
  # /**
  #  * The server was acting as a gateway or proxy and received an invalid response from the upstream server
  #  */
  BAD_GATEWAY_STATUS_CODE = "502";
  # /**
  #  * The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a temporary state
  #  */
  SERVICE_UNAVAILABLE_STATUS_CODE = "503";
  # /**
  #  * The server was acting as a gateway or proxy and did not receive a timely response from the upstream server
  #  */
  GATEWAY_TIMEOUT_STATUS_CODE = "504";
  # /**
  #  * The server is unable to store the representation needed to complete the request
  #  */
  INSUFFICIENT_STORAGE_STATUS_CODE = "507";
  # /**
  #  * The server detected an infinite loop while processing the request
  #  */
  LOOP_DETECTED_STATUS_CODE = "508";
  # /**
  #  * This status code is not specified in any RFC and is returned by certain services, for instance Microsoft Azure and CloudFlare servers: "The 520 error is essentially a “catch-all” response for when the origin server returns something unexpected or something that is not tolerated/in terpreted (protocol violation or empty response)."
  #  */
  UNKNOWN_ERROR_STATUS_CODE = " 520 ";
end