import io
import os
import time
import tempfile
import PIL.Image
import google.generativeai as genai
from app.config import model

# Default Prompts

DEFAULT_IMAGE_PROMPT = "Describe this image in detail."
DEFAULT_DOCUMENT_PROMPT = "Summarize this document."
DEFAULT_AUDIO_PROMPT = "Transcribe this audio and respond to its content."

# Helper Functions

def _get_prompt(message: str, default_prompt: str) -> str:
    """
    Returns the user's message if it exists,
    otherwise returns the default prompt.
    """
    return message.strip() if message.strip() else default_prompt


def _wait_for_file_processing(file):
    """
    Wait until Gemini finishes processing
    the uploaded file.
    """
    while file.state.name == "PROCESSING":
        time.sleep(1)
        file = genai.get_file(file.name)

    if file.state.name == "FAILED":
        raise Exception("File processing failed.")

    return file

# Text Chat

def generate_reply(message: str) -> str:
    """
    Generate a text response.
    """

    response = model.generate_content(message)

    return response.text


# Image Chat

def generate_reply_with_image(
    message: str,
    image_bytes: bytes,
) -> str:
    """
    Generate a response from an uploaded image.
    """

    try:
        image: PIL.Image.Image = PIL.Image.open(
            io.BytesIO(image_bytes)
        )

    except Exception as e:
        raise ValueError(
            f"Invalid image file: {e}"
        )

    prompt = _get_prompt(
        message,
        DEFAULT_IMAGE_PROMPT,
    )

    response = model.generate_content(
        [
            prompt,
            image,
        ]
    )

    return response.text

# Document Chat

def generate_reply_with_document(
    message: str,
    doc_bytes: bytes,
    filename: str,
) -> str:
    """
    Generate a response from an uploaded document.
    """

    suffix = os.path.splitext(filename)[1] if filename else ".bin"

    with tempfile.NamedTemporaryFile(
        delete=False,
        suffix=suffix,
    ) as temp_file:

        temp_file.write(doc_bytes)
        temp_path = temp_file.name

    try:
        uploaded_file = genai.upload_file(
            path=temp_path,
            display_name=filename,
        )

        uploaded_file = _wait_for_file_processing(
            uploaded_file
        )

        prompt = _get_prompt(
            message,
            DEFAULT_DOCUMENT_PROMPT,
        )

        response = model.generate_content(
            [
                prompt,
                uploaded_file,
            ]
        )

        return response.text

    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)

# Voice Chat

def generate_reply_with_voice(
    message: str,
    audio_bytes: bytes,
    filename: str,
) -> str:
    """
    Generate a response from uploaded audio.
    """

    suffix = os.path.splitext(filename)[1] if filename else ".m4a"

    with tempfile.NamedTemporaryFile(
        delete=False,
        suffix=suffix,
    ) as temp_file:

        temp_file.write(audio_bytes)
        temp_path = temp_file.name

    try:
        uploaded_file = genai.upload_file(
            path=temp_path,
            display_name=filename,
        )

        uploaded_file = _wait_for_file_processing(
            uploaded_file
        )

        prompt = _get_prompt(
            message,
            DEFAULT_AUDIO_PROMPT,
        )

        response = model.generate_content(
            [
                prompt,
                uploaded_file,
            ]
        )

        return response.text

    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)