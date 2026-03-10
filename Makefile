IMAGE   := ipxe-no-wait
OUTDIR  := output

.PHONY: build clean

build:
	docker build -t $(IMAGE) .
	mkdir -p $(OUTDIR)
	docker create --name ipxe-extract $(IMAGE) 2>/dev/null || true
	docker cp ipxe-extract:/ipxe-x86_64.iso $(OUTDIR)/
	docker cp ipxe-extract:/ipxe-x86_64.usb $(OUTDIR)/
	docker cp ipxe-extract:/ipxeboot.tar.gz $(OUTDIR)/
	docker rm ipxe-extract

clean:
	rm -rf $(OUTDIR)
	docker rmi $(IMAGE) 2>/dev/null || true
