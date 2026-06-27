from fastapi import APIRouter, HTTPException, UploadFile, File, Form

from app.models import ChatRequest, ChatResponse
from app.services import (
    generate_reply,
    generate_reply_with_image,
    generate_reply_with_document,
    generate_reply_with_voice,
)

router = APIRouter()


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        reply = generate_reply(request.message)
        return ChatResponse(reply=reply)

    except Exception as e:
        print("ERROR:", e)  
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )


@router.post("/chat-with-file", response_model=ChatResponse)
async def chat_with_file(
    file: UploadFile = File(...),
    message: str = Form(default=""),
    type: str = Form(default="image"),
):
    try:
        file_bytes = await file.read()
        filename = file.filename or "upload"

        if type == "image":
            reply = generate_reply_with_image(message, file_bytes)
        elif type == "document":
            reply = generate_reply_with_document(message, file_bytes, filename)
        elif type == "voice":
            reply = generate_reply_with_voice(message, file_bytes, filename)
        else:
            raise HTTPException(
                status_code=400,
                detail=f"Unsupported file type: {type}",
            )

        return ChatResponse(reply=reply)

    except HTTPException:
        raise
    except Exception as e:
        print("ERROR:", e)
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )