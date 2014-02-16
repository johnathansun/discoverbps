class Admin::TextSnippetsController < ApplicationController
	before_filter :authenticate_admin!
	layout 'admin'

	def index
		@text_snippets = TextSnippet.order('location')
	end

	def new
		@text_snippet = TextSnippet.new
	end

  def create
    @text_snippet = TextSnippet.new(params[:text_snippet])
    
    respond_to do |format|
      if @text_snippet.save
        format.html { redirect_to admin_text_snippets_url, notice: 'Text Snippet was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

	def edit
		@text_snippet = TextSnippet.find(params[:id])
	end

	def update
		@text_snippet = TextSnippet.find(params[:id])
    
    respond_to do |format|
      if @text_snippet.update_attributes(params[:text_snippet])
        format.html { redirect_to admin_text_snippets_url, notice: 'Text Snippet was successfully updated.' }          
      else
        format.html { render action: "edit" }
      end
    end
	end

	def destroy
    @text_snippet = TextSnippet.find(params[:id])
    @text_snippet.destroy
    
    respond_to do |format|
      format.html { redirect_to admin_text_snippets_url }
    end
  end
end
