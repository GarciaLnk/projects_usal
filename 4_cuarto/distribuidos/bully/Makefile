PROJECT_NAME := bully-rest
CLIENT_NAME := client
BUILDDIR := build/classes
SRCDIR := src
LIBDIR := lib
JFLAGS := -g
JC := javac -cp "$(LIBDIR)/*" -sourcepath $(SRCDIR) -d $(BUILDDIR)
SRCS := $(shell find $(SRCDIR) -name '*.java')
CLASSES := $(SRCS:$(SRCDIR)/%.java=$(BUILDDIR)/%.class)

client: $(CLASSES)
	jar cvfm $(CLIENT_NAME).jar META-INF/MANIFEST.MF -C $(BUILDDIR) client

server: $(CLASSES)
	cp -rf build/classes/services WebContent/WEB-INF/classes
	jar cvfm $(PROJECT_NAME).war WebContent/META-INF/MANIFEST.MF -C WebContent WEB-INF
	cp -f $(PROJECT_NAME).war $(CATALINA_HOME)/webapps 

$(BUILDDIR)/%.class: $(SRCDIR)/%.java
	mkdir -p $(dir $@)
	$(JC) $(JFLAGS) $<

.PHONY: clean
clean:
	rm -rf $(BUILDDIR)/*
	rm -rf WebContent/WEB-INF/classes/*
	rm -f *.jar
	rm -f *.war
	rm -f $(CATALINA_HOME)/webapps/*.war 
