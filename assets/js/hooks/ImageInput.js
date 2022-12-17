const DROP_CLASSES = ["bg-blue-100", "border-blue-300"]

export const ImageInput = {
    mounted() {
        this.props = {
            height: parseInt(this.el.dataset.height),
            width: parseInt(this.el.dataset.width),
        };
        this.inputEl = this.el.querySelector(`[data-el-input]`);
        this.previewEl = this.el.querySelector(`[data-el-preview]`);
        // File selection
        this.el.addEventListener("click", (event) => {
            this.inputEl.click();
        });
        this.inputEl.addEventListener("change", (event) => {
            const [file] = event.target.files;
            file && this.loadFile(file);
        });
        // Drag and drop
        this.el.addEventListener("dragover", (event) => {
            event.stopPropagation();
            event.preventDefault();
            event.dataTransfer.dropEffect = "copy";
        });
        this.el.addEventListener("drop", (event) => {
            event.stopPropagation();
            event.preventDefault();
            const [file] = event.dataTransfer.files;
            file && this.loadFile(file);
        });
        this.el.addEventListener("dragenter", (event) => {
            this.el.classList.add(...DROP_CLASSES);
        });
        this.el.addEventListener("dragleave", (event) => {
            if (!this.el.contains(event.relatedTarget)) {
                this.el.classList.remove(...DROP_CLASSES);
            }
        });
        this.el.addEventListener("drop", (event) => {
            this.el.classList.remove(...DROP_CLASSES);
        });
    },

    loadFile(file) {
        const reader = new FileReader();
        reader.onload = (readerEvent) => {
            const imgEl = document.createElement("img");
            imgEl.addEventListener("load", (loadEvent) => {
                this.setPreview(imgEl);
                const canvas = this.toCanvas(imgEl);
                const blob = this.canvasToBlob(canvas);
                this.upload("image", [blob]);
            });
            imgEl.src = readerEvent.target.result;
        };
        reader.readAsDataURL(file);
    },
    setPreview(imgEl) {
        // Keep the original image size intact
        const previewImgEl = imgEl.cloneNode();
        previewImgEl.style.maxHeight = "100%";
        this.previewEl.replaceChildren(previewImgEl);
    },

    toCanvas(imgEl) {
        // We resize the image, such that it fits in the configured
        // height x width, but keeping the aspect ratio. We could
        // also easily crop, pad or squash the image, if desired
        const { width, height } = imgEl;
        const { width: boundWidth, height: boundHeight } = this.props;
        const canvas = document.createElement("canvas");
        const ctx = canvas.getContext("2d");
        const widthScale = boundWidth / width;
        const heightScale = boundHeight / height;
        const scale = Math.min(widthScale, heightScale);
        const scaledWidth = Math.round(width * scale);
        const scaledHeight = Math.round(height * scale);
        canvas.width = scaledWidth;
        canvas.height = scaledHeight;
        ctx.drawImage(imgEl, 0, 0, width, height, 0, 0, scaledWidth, scaledHeight);
        return canvas;
    },

    canvasToBlob(canvas) {
        const imageData = canvas
            .getContext("2d")
            .getImageData(0, 0, canvas.width, canvas.height);
        const buffer = this.imageDataToRGBBuffer(imageData);
        const meta = new ArrayBuffer(8);
        const view = new DataView(meta);
        view.setUint32(0, canvas.height, false);
        view.setUint32(4, canvas.width, false);
        return new Blob([meta, buffer], { type: "application/octet-stream" });
    },
    imageDataToRGBBuffer(imageData) {
        const pixelCount = imageData.width * imageData.height;
        const bytes = new Uint8ClampedArray(pixelCount * 3);
        for (let i = 0; i < pixelCount; i++) {
            bytes[i * 3] = imageData.data[i * 4];
            bytes[i * 3 + 1] = imageData.data[i * 4 + 1];
            bytes[i * 3 + 2] = imageData.data[i * 4 + 2];
        }
        return bytes.buffer;
    },
}
