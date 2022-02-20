# frozen_string_literal: true

module Sass
  class Embedded
    # The {Protofier} between Pure Ruby types and Protobuf Ruby types.
    module Protofier
      ONEOF_MESSAGE = EmbeddedProtocol::InboundMessage
                      .descriptor
                      .lookup_oneof('message')
                      .to_h do |field_descriptor|
        [field_descriptor.subtype, field_descriptor.name]
      end

      private_constant :ONEOF_MESSAGE

      module_function

      def from_proto_compile_response(compile_response)
        if compile_response.result == :failure
          raise CompileError.new(
            compile_response.failure.formatted || compile_response.failure.message,
            compile_response.failure.message,
            compile_response.failure.stack_trace,
            from_proto_source_span(compile_response.failure.span)
          )
        end

        CompileResult.new(
          compile_response.success.css,
          compile_response.success.source_map,
          compile_response.success.loaded_urls
        )
      end

      def from_proto_source_span(source_span)
        return nil if source_span.nil?

        Logger::SourceSpan.new(from_proto_source_location(source_span.start),
                               from_proto_source_location(source_span.end),
                               source_span.text,
                               source_span.url,
                               source_span.context)
      end

      def from_proto_source_location(source_location)
        return nil if source_location.nil?

        Logger::SourceLocation.new(source_location.offset,
                                   source_location.line,
                                   source_location.column)
      end

      def from_proto_message(proto)
        message = EmbeddedProtocol::OutboundMessage.decode(proto)
        message.method(message.message).call
      end

      def to_proto_message(message)
        EmbeddedProtocol::InboundMessage.new(
          ONEOF_MESSAGE[message.class.descriptor] => message
        ).to_proto
      end

      def to_proto_syntax(syntax)
        case syntax&.to_sym
        when :scss
          EmbeddedProtocol::Syntax::SCSS
        when :indented
          EmbeddedProtocol::Syntax::INDENTED
        when :css
          EmbeddedProtocol::Syntax::CSS
        else
          raise ArgumentError, 'syntax must be one of :scss, :indented, :css'
        end
      end

      def to_proto_output_style(style)
        case style&.to_sym
        when :expanded
          EmbeddedProtocol::OutputStyle::EXPANDED
        when :compressed
          EmbeddedProtocol::OutputStyle::COMPRESSED
        else
          raise ArgumentError, 'style must be one of :expanded, :compressed'
        end
      end
    end

    private_constant :Protofier
  end
end
