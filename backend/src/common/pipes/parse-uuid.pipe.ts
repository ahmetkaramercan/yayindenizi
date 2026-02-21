import { PipeTransform, Injectable, BadRequestException } from '@nestjs/common';

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

@Injectable()
export class ParseUUIDPipe implements PipeTransform<string> {
  constructor(private readonly paramName = 'id') {}

  transform(value: string): string {
    if (!UUID_REGEX.test(value)) {
      throw new BadRequestException(`${this.paramName} must be a valid UUID`);
    }
    return value;
  }
}
