create procedure usp_publish_content
	@content xml,
	@tags publish_tags_type readonly
as	
begin
	declare @sql nvarchar(max) = N'send on conversation (';
	declare @cnt int = 0;
	declare @dh uniqueidentifier;
	declare @comma nvarchar(2) = N'';
	
	declare crs cursor static read_only forward_only for
		select distinct conversation_handle
		from subscriptions s
		join @tags t on t.tag like s.tag;
		
	open crs;
	fetch next from crs into @dh;
	while 0 = @@fetch_status
	begin
	
		set @sql += @comma  + N'''' + cast(@dh as nvarchar(36)) + N'''';
		set @comma = N', ';
		set @cnt += 1;
		fetch next from crs into @dh;
	end
	close crs;
	deallocate crs;
	
	if @cnt > 0
	begin
		set @sql+= N') message type subscription_content (@content)';
		exec sp_executesql @sql, N'@content xml', @content;
	end
end
go